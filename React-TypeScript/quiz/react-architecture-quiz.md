# React Architecture Self-Assessment Quiz

## Part 1: Component Architecture (15 Questions, 4 points each = 60 points)

### Q1: Component Folder Structure
For a 200+ component app, which structure is most scalable?
- A) Single folder with all components
- B) Feature-based folders with components, hooks, services
- C) By component type (atoms, molecules, etc.)
- D) Flat structure with name prefixes

**Answer: B** - Feature-based organization scales best with teams.

---

### Q2: Smart vs Presentational Components
Where should API calls be made?
- A) Presentational components
- B) Smart/Container components
- C) Both equally
- D) Utility functions only

**Answer: B** - Smart components handle side effects.

---

### Q3: Props Design
What pattern prevents prop drilling?
- A) Pass all props down
- B) Context API or state management
- C) Global variables
- D) No solution needed

**Answer: B** - Context/Redux prevents prop drilling.

---

### Q4: Component Composition
Favor composition over inheritance in React because:
- A) It's simpler
- B) More reusable and flexible
- C) Required by React
- D) Better performance

**Answer: B** - Composition is more flexible.

---

### Q5: Atomic Design
What is an organism in atomic design?
- A) Basic building block
- B) Combination of molecules
- C) Full page
- D) Data structure

**Answer: B** - Organism combines molecules.

---

### Q6: Render Props Pattern
When would you use render props?
- A) Always
- B) To share logic across components
- C) For styling
- D) Never

**Answer: B** - Render props enable logic sharing.

---

### Q7: Higher-Order Components
What is a HOC?
- A) A component that renders HTML
- B) A function that wraps component with additional logic
- C) A database query
- D) A styling library

**Answer: B** - HOC wraps and enhances components.

---

### Q8: Custom Hooks
What enables custom hook extraction?
- A) Complex component logic
- B) Reuse of logic across components
- C) Separation of concerns
- D) All of above

**Answer: D** - Hooks enable all benefits.

---

### Q9: Hook Rules
Which violates hook rules?
- A) Calling hook at top level
- B) Conditional hook call
- C) Hook in custom hook
- D) Hook with dependency array

**Answer: B** - Hooks must be conditional-free.

---

### Q10: Error Boundary
What errors do Error Boundaries NOT catch?
- A) Render errors
- B) Lifecycle errors
- C) Event handler errors
- D) Constructor errors

**Answer: C** - Use try-catch for event handlers.

---

### Q11: Key Prop
Why is key important in lists?
- A) Improves styling
- B) Helps React identify which items changed
- C) Required by HTML
- D) No effect

**Answer: B** - Key helps React reconciliation.

---

### Q12: Memo
When should you use React.memo?
- A) Always
- B) For expensive renders with same props
- C) For all components
- D) Never

**Answer: B** - Memoize expensive components.

---

### Q13: useCallback
When is useCallback necessary?
- A) Always
- B) When function passed to memoized child
- C) For performance
- D) Never

**Answer: B** - Stabilize functions for memo.

---

### Q14: useMemo
When is useMemo needed?
- A) Always
- B) For expensive calculations
- C) For object/array creation
- D) For performance

**Answer: B,C** - Avoid recalculation and object creation.

---

### Q15: useEffect Dependency
Missing dependencies can cause:
- A) Better performance
- B) Stale closures and bugs
- C) Faster rendering
- D) No issues

**Answer: B** - Missing deps cause bugs.

---

## Part 2: State Management & Performance (20 Questions, 4 points each = 80 points)

### Q16: Redux Store Design
How should state be normalized?
- A) Deeply nested
- B) Flat with IDs as keys
- C) No normalization
- D) Depends on data

**Answer: B** - Normalization prevents duplication.

---

### Q17: Redux Selectors
Why use memoized selectors?
- A) Faster database queries
- B) Prevent unnecessary component re-renders
- C) Smaller bundle size
- D) No reason

**Answer: B** - Memoization prevents re-renders.

---

### Q18: Context API
When to use Context over Redux?
- A) Always use Redux
- B) Simple state, few updates
- C) Complex derived state
- D) Never use Context

**Answer: B** - Context for simple state.

---

### Q19: Code Splitting
What does code splitting achieve?
- A) Better code quality
- B) Smaller initial bundle, faster load
- C) More lines of code
- D) Better performance overall

**Answer: B** - Smaller bundle on first load.

---

### Q20: Lazy Loading
Lazy loading components helps with:
- A) Development speed
- B) Bundle size
- C) Runtime performance
- D) A and B

**Answer: D** - Lazy loading reduces initial bundle.

---

### Q21: Virtual Scrolling
Use virtual scrolling for:
- A) All lists
- B) Lists with 10K+ items
- C) Mobile only
- D) Never

**Answer: B** - Optimize large lists.

---

### Q22: Debouncing/Throttling
Debounce is used for:
- A) Click events
- B) Search input changes
- C) Page loads
- D) Renders

**Answer: B** - Debounce reduces API calls.

---

### Q23: Bundle Analysis
Why analyze bundles?
- A) Code quality
- B) Find unused/duplicate code
- C) Team collaboration
- D) Documentation

**Answer: B** - Find optimization opportunities.

---

### Q24: Tree Shaking
Tree shaking removes:
- A) CSS files
- B) Unused exported code
- C) Comments
- D) Images

**Answer: B** - Eliminates dead code.

---

### Q25: PWA
What makes app Progressive Web App?
- A) Service worker, manifest, HTTPS
- B) React framework
- C) Good CSS
- D) Mobile-only

**Answer: A** - Service worker + manifest + HTTPS.

---

### Q26: Offline Support
How to support offline in React?
- A) Cache API + Service Worker
- B) IndexedDB for storage
- C) Both
- D) Not possible

**Answer: C** - Cache + storage for offline.

---

### Q27: Performance Monitoring
How to monitor React performance?
- A) Console.log everywhere
- B) React DevTools Profiler
- C) Web Vitals (LCP, FID, CLS)
- D) B and C

**Answer: D** - Use DevTools and Vitals.

---

### Q28: Image Optimization
Best for image performance?
- A) Large JPEG files
- B) WebP with fallback
- C) Lazy loading images
- D) B and C

**Answer: D** - Modern formats + lazy load.

---

### Q29: Font Loading
How to prevent FOUT?
- A) font-display: auto
- B) font-display: swap
- C) font-display: block
- D) Load all fonts

**Answer: C** - Block causes brief delay, prevents flicker.

---

### Q30: Hydration
Hydration is needed when:
- A) Using hooks
- B) Using Context
- C) Server-side rendering
- D) Always

**Answer: C** - SSR requires hydration.

---

### Q31: Time Slicing
React Concurrent features help with:
- A) Older browsers
- B) Large renders non-blocking
- C) Styling
- D) Routing

**Answer: B** - Non-blocking rendering.

---

### Q32: Error Recovery
Best practice for component errors?
- A) Let app crash
- B) Error Boundary + Fallback UI
- C) Ignore errors
- D) Console.error

**Answer: B** - Boundary + graceful fallback.

---

### Q33: Testing Approach
Best for React component testing?
- A) Only unit tests
- B) Behavior-based, not implementation
- C) Snapshot testing only
- D) No testing

**Answer: B** - Test behavior.

---

### Q34: Accessibility
WCAG level to target?
- A) None
- B) Level A
- C) Level AA
- D) Level AAA

**Answer: C** - AA is standard requirement.

---

### Q35: Security
Prevent XSS in React with:
- A) dangerouslySetInnerHTML always
- B) Escape HTML, avoid innerHTML
- C) Store secrets in localStorage
- D) No protection needed

**Answer: B** - Escape and avoid innerHTML.

---

## Part 3: Architecture Decisions (15 Questions, 6 points each = 90 points)

### Q36: Monorepo vs Multi-repo
Use monorepo for:
- A) Single app only
- B) Multiple related packages/apps
- C) Unrelated projects
- D) Never

**Answer: B** - Monorepo for related projects.

---

### Q37: Form Library
When build custom form hooks?
- A) All forms
- B) Simple forms, then formik/react-hook-form for complex
- C) Never
- D) Enterprise only

**Answer: B** - Custom for simple, library for complex.

---

### Q38: State Colocation
Where should state live?
- A) Root component always
- B) Closest to where it's used
- C) Global state always
- D) Somewhere else

**Answer: B** - Colocate state where used.

---

### Q39: Micro-Frontends
Use micro-frontends when:
- A) Always
- B) Large team, independent features
- C) Never
- D) Small projects

**Answer: B** - Multi-team projects benefit.

---

### Q40: Design System
Maintain design system in:
- A) Embedded in app
- B) Separate npm package
- C) Documentation only
- D) No system needed

**Answer: B** - Separate package for reuse.

---

### Q41: Type Safety
TypeScript benefits:
- A) Slower development
- B) Catches errors early, better DX
- C) Required always
- D) No benefit

**Answer: B** - Early error detection.

---

### Q42: Testing Coverage
Aim for:
- A) 100% always
- B) 80%+ for critical paths
- C) No testing
- D) 50% minimum

**Answer: B** - 80%+ for quality.

---

### Q43: Documentation
Most important documentation:
- A) Every line of code
- B) Architecture decisions, API usage
- C) No documentation
- D) Only type definitions

**Answer: B** - High-level guidance.

---

### Q44: CI/CD Pipeline
Essential for React apps:
- A) Not needed
- B) Linting, tests, build, deploy
- C) Only tests
- D) Only deployment

**Answer: B** - Complete pipeline.

---

### Q45: Deployment Strategy
Zero-downtime deployment with React:
- A) Simple reload
- B) Blue-green or rolling deployment
- C) Restart all servers
- D) Not possible

**Answer: B** - Blue-green or rolling.

---

### Q46: Version Management
Semantic versioning means:
- A) Random numbers
- B) MAJOR.MINOR.PATCH (breaking.feature.fix)
- C) Sequential numbering
- D) No versioning

**Answer: B** - Standard semantic versioning.

---

### Q47: Browser Support
Modern React targets:
- A) All browsers
- B) Last 2 major versions
- C) IE 11
- D) Mobile only

**Answer: B** - Recent browsers standard.

---

### Q48: Build Tool
Modern React projects use:
- A) Webpack only
- B) Vite for speed, Webpack for features
- C) No build tool
- D) Manual bundling

**Answer: B** - Vite modern, Webpack for complex.

---

### Q49: Package Management
Best practice:
- A) npm
- B) yarn
- C) pnpm
- D) Any is fine if consistent

**Answer: D** - Consistency matters most.

---

### Q50: Learning Path
Master React architecture by:
- A) Read docs only
- B) Build projects, solve challenges, study patterns
- C) Memorize everything
- D) Avoid learning

**Answer: B** - Hands-on learning best.

---

## Scoring Guide

### Total Points: 230

| Score Range | Level | Recommendation |
|------------|-------|-----------------|
| 0-75 | Beginner | Review components and hooks basics |
| 75-120 | Intermediate | Focus on state management and performance |
| 120-160 | Advanced | Practice architecture patterns |
| 160-200 | Expert | Interview and system design prep |
| 200+ | Master | Ready for senior/architect role |

---

## Performance Benchmarks

### If you scored < 100:
- Review React fundamentals
- Practice hooks exercises
- Study component patterns
- Build simple projects

### If you scored 100-150:
- Learn state management deeply
- Study performance optimization
- Build medium-complexity apps
- Interview question practice

### If you scored 150-200:
- Complete all 8 coding challenges
- Design a full architecture
- Mentor junior developers
- Explore advanced patterns

### If you scored 200+:
- Review architecture decisions
- Study system design
- Interview other candidates
- Stay current with React evolution

---

## Related Learning Resources

- React documentation
- Redux/Recoil documentation
- Performance profiling tools
- Testing libraries (Jest, React Testing Library)
- TypeScript handbook
- Webpack/Vite documentation
- Next.js/Remix frameworks

---

## Common Mistakes to Avoid

1. **Over-engineering:** Don't use Redux for simple state
2. **Prop drilling:** Use Context or state management
3. **Tight coupling:** Keep components loosely coupled
4. **Ignoring performance:** Profile before optimizing
5. **No error handling:** Always plan recovery
6. **Testing implementation:** Test behavior, not internals
7. **Security gaps:** Always sanitize user input
8. **Accessibility ignored:** WCAG AA is standard

---

**Total Study Time:** 1-2 hours
**Difficulty:** Intermediate to Advanced
**Topics Covered:** All 9 architecture patterns from Chapter 09

