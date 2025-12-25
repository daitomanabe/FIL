# FIL Design System

This document outlines the design system for the **FIL** project. It is intended to be used as a source of truth for AI agents and developers when generating new web interfaces or maintaining existing ones. The aesthetic is defined as **Technical, Minimalist, Architectural, and Dark Mode-first**.

## 1. Core Design Philosophy
- **Keywords**: Independent, Salon, 21st Century, Cross-disciplinary, Technical, Brutalist-Lite.
- **Visual Style**: High contrast (White on Black), fine lines (1px), ample whitespace (negative space), strict grid alignment.
- **Atmosphere**: Professional, mysterious, high-end, gallery-like.

## 2. Design Tokens (CSS Variables)

Copy these into the `:root` of your CSS or tailwind config.

```css
:root {
  /* Colors */
  --canvas-bg: #000000;          /* Deepest background */
  --panel-bg: #000000;           /* Component background */
  --panel-text: #ffffff;         /* Primary text */
  --panel-border: #333333;       /* Subtle separators */
  --panel-control-bg: #111111;   /* Button/Card backgrounds */
  --panel-control-bg-hover: #222222; /* Hover state */
  
  /* Accents & Utilities */
  --grid-line: rgba(255, 255, 255, 0.12);
  --text-muted: rgba(255, 255, 255, 0.6);
  --text-faint: rgba(255, 255, 255, 0.3);
  
  /* Typrography Weights */
  --fw-thin: 100;
  --fw-light: 200;
  --fw-regular: 300; /* Used for body often */
  --fw-normal: 400;
  --fw-bold: 500;
  
  /* Layout */
  --max-width: 1000px;
  --section-spacing: 8rem;
  --radius-sm: 4px;
}
```

## 3. Typography
Font Stack: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`

- **H1 (Hero Title)**
  - Size: Responsive `8vw`
  - Weight: `100` (Thin)
  - Letter Spacing: `0em`
  - Case: Standard/Capitalized
  
- **H2 (Section Headers)**
  - Size: `2rem`
  - Weight: `200` (Extra Light)
  - Letter Spacing: `0.05em`
  - Decoration: `border-bottom: 1px solid var(--panel-border)`
  
- **H3 (Card Headers)**
  - Size: `1.1rem` - `1.2rem`
  - Weight: `400` (Normal)
  - Color: `rgba(255, 255, 255, 0.5)` or White depending on context.

- **Body Text**
  - Weight: `300` (Light) or `400` (Normal)
  - Line Height: `1.5` - `1.8`
  - Color: `var(--panel-text)` or `rgba(255, 255, 255, 0.7)`

- **Navigation / Links**
  - Weight: `500`
  - Style: Simple, no decoration until hover (or subtle underline).

## 4. Components

### A. Buttons (.btn)
Technical, rectangular buttons with subtle rounded corners.
```css
.btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 2rem;
  background: var(--panel-control-bg); /* #111 */
  color: var(--panel-text);
  border: 1px solid var(--panel-border); /* #333 */
  border-radius: 4px;
  font-weight: 500;
  transition: all 0.2s;
}

.btn:hover {
  transform: translateY(-2px);
  background: var(--panel-control-bg-hover); /* #222 */
  border-color: var(--panel-text); /* White */
}
```

### B. Cards (.concept-item, .spec-card)
Minimal container with border only.
```css
.card {
  background: transparent;
  padding: 2rem;
  border: 1px solid var(--panel-border);
  border-radius: 0px; /* Sharp or use 4px if consistent */
  transition: transform 0.3s, background 0.3s, border-color 0.3s;
}

.card:hover {
  background: var(--panel-control-bg);
  border-color: var(--panel-text);
  transform: translateY(-5px);
}
```

### C. Navigation Bar
- Position: `fixed` top.
- Blend Mode: `mix-blend-mode: difference` (Ensures visibility over any background).
- Layout: Flexbox, Space Between.
- Padding: `2rem 3rem`.

## 5. Motion Guidelines (Framer Motion)
Animation should be slow, smooth, and elegant. Avoid bouncy or springy physics unless for specific micro-interactions.

- **Fade In / Slide Up**: `duration: 1s`, `ease: "easeInOut"`
- **Stagger**: `delay: index * 0.1`
- **Hover**: Quick transitions `0.2s` or `0.3s`.

## 6. Implementation Example (React/HTML)

```jsx
<section style={{ margin: '8rem 0' }}>
  <h2 style={{ 
    fontSize: '2rem', 
    fontWeight: 200, 
    borderBottom: '1px solid #333', 
    paddingBottom: '1rem' 
  }}>
    Section Title
  </h2>
  
  <div style={{ 
    display: 'grid', 
    gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
    gap: '2rem' 
  }}>
    {/* Card Component */}
    <div className="concept-item">
      <h3>Card Title</h3>
      <p>Card content goes here. Clean and minimal.</p>
    </div>
  </div>
</section>
```
