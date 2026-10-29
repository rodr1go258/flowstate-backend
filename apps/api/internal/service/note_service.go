package service

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"flowstate/api/internal/model"
	"flowstate/api/internal/repository"
)

type NoteService struct {
	repo     repository.NoteRepository
	teamRepo repository.TeamRepository
}

func NewNoteService(repo repository.NoteRepository, teamRepo repository.TeamRepository) *NoteService {
	return &NoteService{repo: repo, teamRepo: teamRepo}
}

func (s *NoteService) Create(ctx context.Context, userID string, req model.CreateNoteRequest) (*model.Note, error) {
	tags, _ := json.Marshal(req.Tags)
	tagsRaw := json.RawMessage(tags)
	note, err := s.repo.Create(ctx, userID, req.Title, req.Content, req.TeamID, tagsRaw)
	if err != nil {
		return nil, fmt.Errorf("create note: %w", err)
	}

	s.repo.ResolveLinks(ctx, note.Title, note.ID)

	titles := ExtractWikiLinks(req.Content)
	for _, title := range titles {
		if ierr := s.repo.InsertLink(ctx, note.ID, nil, title); ierr != nil {
			log.Printf("[DEBUG links] InsertLink failed (create) note=%s title=%q: %v", note.ID, title, ierr)
		}
		if existing, ferr := s.findNoteByExactTitle(ctx, userID, title); ferr == nil && existing != nil {
			if rerr := s.repo.ResolveLinks(ctx, title, existing.ID); rerr != nil {
				log.Printf("[DEBUG links] ResolveLinks failed (create) title=%q target=%s: %v", title, existing.ID, rerr)
			}
		} else if ferr != nil {
			log.Printf("[DEBUG links] findNoteByExactTitle failed title=%q: %v", title, ferr)
		}
	}
	return note, nil
}

// findNoteByExactTitle busca una nota del usuario cuyo título coincida exactamente
// (SearchByUser hace match parcial con ILIKE, así que filtramos por igualdad exacta).
func (s *NoteService) findNoteByExactTitle(ctx context.Context, userID, title string) (*model.Note, error) {
	notes, err := s.repo.SearchByUser(ctx, userID, title, 20, 0)
	if err != nil {
		return nil, err
	}
	for i := range notes {
		if notes[i].Title == title {
			return &notes[i], nil
		}
	}
	return nil, nil
}

func (s *NoteService) GetByID(ctx context.Context, userID, id string) (*model.Note, error) {
	note, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, model.ErrNotFound
	}
	if note.AuthorID != userID {
		if note.TeamID != nil {
			_, err := s.teamRepo.GetMember(ctx, userID, *note.TeamID)
			if err != nil {
				return nil, model.ErrNotFound
			}
		} else {
			return nil, model.ErrNotFound
		}
	}
	return note, nil
}

func (s *NoteService) List(ctx context.Context, userID string, teamID *string, limit, offset int) ([]model.Note, error) {
	if teamID != nil {
		return s.repo.ListByTeam(ctx, *teamID, limit, offset)
	}
	return s.repo.ListByUser(ctx, userID, limit, offset)
}

func (s *NoteService) Search(ctx context.Context, userID string, query *string, teamID *string, limit, offset int) ([]model.Note, error) {
	q := ""
	if query != nil {
		q = *query
	}
	if q == "" {
		return s.List(ctx, userID, teamID, limit, offset)
	}
	if teamID != nil {
		return s.repo.SearchByTeam(ctx, *teamID, q, limit, offset)
	}
	return s.repo.SearchByUser(ctx, userID, q, limit, offset)
}

func (s *NoteService) Update(ctx context.Context, userID, noteID string, req model.UpdateNoteRequest) (*model.Note, error) {
	note, err := s.repo.GetByID(ctx, noteID)
	if err != nil {
		return nil, model.ErrNotFound
	}
	if note.AuthorID != userID {
		return nil, model.ErrForbidden
	}

	var tags, sharedWith json.RawMessage
	if req.Tags != nil {
		t, _ := json.Marshal(req.Tags)
		tags = json.RawMessage(t)
	}
	if req.SharedWith != nil {
		s, _ := json.Marshal(req.SharedWith)
		sharedWith = json.RawMessage(s)
	}

	updated, err := s.repo.Update(ctx, noteID, req.Title, req.Content, tags, req.IsPublic, sharedWith, req.TeamID)
	if err != nil {
		return nil, err
	}

	s.repo.ResolveLinks(ctx, updated.Title, updated.ID)

	if req.Content != nil {
		log.Printf("[DEBUG links] Update note=%s title=%q content=%q", note.ID, updated.Title, *req.Content)
		// Limpiamos los links previos de esta nota antes de reinsertar, para no
		// dejar links huérfanos con títulos viejos (p. ej. si se corrigió un typo
		// en un [[wikilink]]) dando vueltas en la base de datos.
		if derr := s.repo.DeleteLinks(ctx, note.ID); derr != nil {
			log.Printf("[DEBUG links] DeleteLinks failed note=%s: %v", note.ID, derr)
		}

		titles := ExtractWikiLinks(*req.Content)
		log.Printf("[DEBUG links] extracted titles=%v", titles)
		for _, title := range titles {
			if ierr := s.repo.InsertLink(ctx, note.ID, nil, title); ierr != nil {
				log.Printf("[DEBUG links] InsertLink failed (update) note=%s title=%q: %v", note.ID, title, ierr)
			}
			existing, ferr := s.findNoteByExactTitle(ctx, userID, title)
			if ferr != nil {
				log.Printf("[DEBUG links] findNoteByExactTitle failed title=%q: %v", title, ferr)
				continue
			}
			if existing != nil {
				if rerr := s.repo.ResolveLinks(ctx, title, existing.ID); rerr != nil {
					log.Printf("[DEBUG links] ResolveLinks failed (update) title=%q target=%s: %v", title, existing.ID, rerr)
				}
			} else {
				log.Printf("[DEBUG links] no existing note found for title=%q", title)
			}
		}
	}
	return updated, nil
}

func (s *NoteService) Delete(ctx context.Context, userID, noteID string) error {
	note, err := s.repo.GetByID(ctx, noteID)
	if err != nil {
		return model.ErrNotFound
	}
	if note.AuthorID != userID {
		return model.ErrForbidden
	}
	return s.repo.Delete(ctx, noteID)
}

func (s *NoteService) ShareToTeam(ctx context.Context, userID, noteID string, req model.ShareNoteRequest) (*model.Note, error) {
	note, err := s.repo.GetByID(ctx, noteID)
	if err != nil {
		return nil, model.ErrNotFound
	}
	if note.AuthorID != userID {
		return nil, model.ErrForbidden
	}
	updated, err := s.repo.ShareToTeam(ctx, noteID, req.TeamID)
	if err != nil {
		return nil, err
	}
	return updated, nil
}

func (s *NoteService) ListLinks(ctx context.Context, noteID string) ([]model.NoteLink, error) {
	return s.repo.GetLinks(ctx, noteID)
}

func (s *NoteService) AddLink(ctx context.Context, userID, noteID string, req model.AddNoteLinkRequest) error {
	note, err := s.repo.GetByID(ctx, noteID)
	if err != nil {
		return model.ErrNotFound
	}
	if note.AuthorID != userID {
		return model.ErrForbidden
	}
	return s.repo.InsertLink(ctx, noteID, req.TargetNoteID, req.TargetTitle)
}
