# CrossFit Interval Timer - Web Application

A modern web-based CrossFit interval timer built with **React + Vite**, featuring a **glassmorphism design** with **gradient backgrounds**. This serves as a UI/UX prototype before translation to Swift/iOS.

## Features

- **Timer Modes**: Tabata, EMOM, and Custom interval configurations
- **Glassmorphism Design**: Modern iOS 17+ aesthetic with frosted glass effects
- **Gradient Backgrounds**: Dynamic color transitions based on timer state
- **Date-Based Timer**: Accurate timing using Date.now() to prevent drift
- **Audio Feedback**: Web Audio API beeps for state transitions
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- **Single-Screen Layout**: All features visible without scrolling

## Tech Stack

- **React 18** - UI components
- **Vite** - Build tool & dev server
- **CSS3** - Glassmorphism, gradients, animations
- **Web Audio API** - Sound feedback

## Project Structure

```
crossfit-timer-web/
├── src/
│   ├── components/
│   │   ├── TimerDisplay.jsx       # Circular progress with time display
│   │   ├── StateIndicator.jsx     # WORK/REST/PAUSED badge
│   │   ├── TimerControls.jsx      # Play/pause/reset buttons
│   │   └── ConfigPanel.jsx        # Configuration inputs
│   ├── hooks/
│   │   └── useTimer.js            # Timer logic hook
│   ├── utils/
│   │   ├── timerEngine.js         # Date-based timer calculations
│   │   └── formatTime.js          # Time formatting utilities
│   ├── App.jsx                    # Main app component
│   ├── App.css                    # Design system & global styles
│   └── main.jsx                   # Entry point
```

## Getting Started

### Installation

```bash
npm install
```

### Development Server

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

### Production Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Usage

### Quick Presets

- **Tabata**: 20s work / 10s rest × 8 rounds
- **EMOM**: 1min work × 10 rounds
- **Custom**: 2min work / 1min rest × 5 rounds

### Custom Configuration

1. Set work interval (minutes and seconds)
2. Set rest interval (minutes and seconds)
3. Set number of rounds (1-99)
4. Click **Start** to begin

### Controls

- **Play**: Start the workout
- **Pause**: Pause the current interval
- **Resume**: Continue from where you paused
- **Reset**: Return to idle state

## Design System

### Color Gradients

- **Idle**: Blue gradient (#4facfe → #00f2fe)
- **Work**: Purple gradient (#667eea → #764ba2)
- **Rest**: Pink/Red gradient (#f093fb → #f5576c)
- **Finished**: Green gradient (#43e97b → #38f9d7)

### Glassmorphism

All cards use:
- Semi-transparent background: `rgba(255, 255, 255, 0.1)`
- Backdrop blur: `blur(10px)`
- Subtle borders: `rgba(255, 255, 255, 0.2)`
- Drop shadows for depth

### Audio Feedback

- **Work Start**: 800Hz beep (200ms)
- **Rest Start**: 600Hz beep (200ms)
- **Workout Complete**: 1000Hz beep (500ms)

## Translation to Swift/iOS

This web application uses design patterns that directly translate to SwiftUI:

### Timer Logic
- Date-based calculations → Matches iOS `TimerEngine.swift`
- State machine → Maps to SwiftUI `@State` and enums

### Design Translation
- `backdrop-filter: blur()` → `.background(.ultraThinMaterial)`
- `linear-gradient()` → `LinearGradient(colors:startPoint:endPoint:)`
- `transition` → `.animation(.easeInOut(duration: 0.6))`
- `transform: scale()` → `.scaleEffect()`

### Component Mapping
- React components → SwiftUI `View` structs
- `useState` → `@State` properties
- `useEffect` → `.onAppear()` and `.onChange()`

## Browser Support

- Chrome/Edge (recommended)
- Safari (WebKit)
- Firefox
- Modern mobile browsers

## Performance

- **60fps animations** using GPU-accelerated CSS
- **No timer drift** with date-based calculations
- **Optimized builds** with Vite tree-shaking
- **Smooth transitions** with CSS transforms

## License

MIT

## Built With

React + Vite | Glassmorphism Design | Web Audio API
