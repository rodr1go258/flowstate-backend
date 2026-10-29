import React, { useEffect, useMemo, useRef, ReactNode, RefObject } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

interface ScrollFloatProps {
  children: ReactNode;
  scrollContainerRef?: RefObject<HTMLElement>;
  containerClassName?: string;
  textClassName?: string;
  animationDuration?: number;
  ease?: string;
  scrollStart?: string;
  scrollEnd?: string;
  stagger?: number;
}

const ScrollFloat: React.FC<ScrollFloatProps> = ({
  children,
  scrollContainerRef,
  containerClassName = '',
  textClassName = '',
  animationDuration = 1,
  ease = 'back.inOut(2)',
  scrollStart = 'center bottom+=50%',
  scrollEnd = 'bottom bottom-=40%',
  stagger = 0.03
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const isTextChild = typeof children === 'string';

  const splitText = useMemo(() => {
    if (!isTextChild) return null;
    const text = children as string;
    return text.split('').map((char, index) => (
      <span className="inline-block word" key={index}>
        {char === ' ' ? '\u00A0' : char}
      </span>
    ));
  }, [children, isTextChild]);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const scroller = scrollContainerRef && scrollContainerRef.current ? scrollContainerRef.current : window;

    if (isTextChild) {
      // Contenido de texto: animamos letra por letra, como antes.
      const charElements = el.querySelectorAll('.inline-block');
      gsap.fromTo(
        charElements,
        {
          willChange: 'opacity, transform',
          opacity: 0,
          yPercent: 120,
          scaleY: 2.3,
          scaleX: 0.7,
          transformOrigin: '50% 0%'
        },
        {
          duration: animationDuration,
          ease: ease,
          opacity: 1,
          yPercent: 0,
          scaleY: 1,
          scaleX: 1,
          stagger: stagger,
          scrollTrigger: { trigger: el, scroller, start: scrollStart, end: scrollEnd, scrub: true }
        }
      );
    } else {
      // Contenido no textual (formularios, cards, etc.): fade + slight rise del bloque completo.
      gsap.fromTo(
        el,
        { opacity: 0, y: 24 },
        {
          duration: animationDuration,
          ease: ease,
          opacity: 1,
          y: 0,
          scrollTrigger: { trigger: el, scroller, start: scrollStart, end: scrollEnd, scrub: true }
        }
      );
    }
  }, [scrollContainerRef, animationDuration, ease, scrollStart, scrollEnd, stagger, isTextChild]);

  if (!isTextChild) {
    return (
      <div ref={containerRef} className={containerClassName}>
        {children}
      </div>
    );
  }

  return (
    <h2 ref={containerRef} className={`my-5 overflow-hidden ${containerClassName}`}>
      <span className={`inline-block text-[clamp(1.6rem,4vw,3rem)] leading-[1.5] ${textClassName}`}>{splitText}</span>
    </h2>
  );
};

export default ScrollFloat;
