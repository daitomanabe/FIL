# FIL Design System

This document defines the design tone and manner for the FIL project, extracted from [https://terra.in/fil/](https://terra.in/fil/).
It is intended to be used by AI agents and developers to maintain consistency across all FIL-related projects.

## Tone and Manner
- **Aesthetic**: Minimalist, technical, dark mode, precision-oriented.
- **Vibe**: Similar to professional creative coding tools or high-end data visualization interfaces.
- **Motion**: Subtle, smooth transitions (`ease-out`), no flashy or bouncing animations.

## Core Design Tokens

### Colors
| Token | Value | Description |
|---|---|---|
| `--canvas-bg` | `#000000` | Main background color for the visualization area |
| `--panel-bg` | `#000000` | Background for UI panels |
| `--panel-text` | `#ffffff` | Primary text color |
| `--panel-border` | `#333333` | Borders for panels and separators |
| `--grid-line` | `rgba(255,255,255,0.12)` | Subtle grid lines |
| `--segment-color` | `#ffffff` | Highlight/Active element color |
| `--panel-control-bg` | `#111111` | Background for buttons/controls |
| `--panel-control-bg-hover` | `#222222` | Hover state for controls |
| `--panel-input-bg` | `#111111` | Background for input fields |
| `--panel-input-border` | `#444444` | Border for input fields |
| `--segment-label-bg` | `rgba(255,255,255,0.4)` | Background for floating labels |
| `--segment-label-text` | `#000000` | Text color for labels on light backgrounds |

### Typography
- **Font Family**: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`
- **Base Size**: `16px`
- **Line Height**: `1.5`
- **Weight**: Regular (400) for body, Bold (700) for headers.

### Layout
- **Grid System**: The design implies a strict grid system.
    - Base Unit: `10px` (`--cell`)
- **Spacing**: Compact, utility-focused.

## Usage Guide (for AI)

When generating UI for FIL projects:
1.  **Always start with the CSS Variables**: Define the root variables first.
2.  **Use specific hex codes**: Do not use generic names like "red" or "blue". Use the token values.
3.  **Strict Dark Mode**: The interface should be predominantly black (`#000000`) and dark grey.
4.  **Borders**: Use thin, subtle borders (`1px solid var(--panel-border)`) to define structure instead of shadows.
5.  **Simplicity**: Avoid decorative images. Use code-driven graphics or simple geometric shapes.

## CSS Snippet
```css
:root {
  --canvas-bg: #000000;
  --cell: 10px;
  --cols: 145; /* Adjust based on viewport */
  --grid-line: rgba(255, 255, 255, 0.12);
  --panel-bg: #000000;
  --panel-border: #333333;
  --panel-control-bg: #111111;
  --panel-control-bg-hover: #222222;
  --panel-input-bg: #111111;
  --panel-input-border: #444444;
  --panel-text: #ffffff;
  --rows: 86; /* Adjust based on viewport */
  --seg-duration: 0.3s;
  --seg-ease: ease-out;
  --segment-color: #ffffff;
  --segment-label-bg: rgba(255, 255, 255, 0.4);
  --segment-label-text: #000000;

  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  color: var(--panel-text);
  background-color: var(--canvas-bg);
}

body {
    margin: 0;
    padding: 0;
    overflow: hidden; /* Typical for "app-like" vibe */
}
```
