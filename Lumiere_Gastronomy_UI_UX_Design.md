# Lumière Gastronomy (Course UI/UX Project)

## 1) Concept & Goals
Lumière Gastronomy is a premium culinary discovery app designed to feel elegant and calm (not “fast-food”). The UI emphasizes:
- High visual hierarchy (clear headings, strong spacing)
- Warm, appetizing color palette (cream + orange + subtle red)
- Premium components (rounded cards, soft shadows, glass effects)
- A smooth user flow from discovery to customization to cart

## 2) Brand & Design System
### Color Palette (Warm + Premium)
- **Cream background**: `#FFF9F1` (calm, clean, “gallery-like”)
- **Orange primary (CTA/Highlight)**: `#FF5722` (appetite, energy, action)
- **Red accent (focus/selection)**: `#D32F2F` (attention for “selected” states)
- **Dark gray (readable text)**: `#333333` (premium, not harsh)
- **Light gray (secondary text)**: `#9E9E9E` (supporting information)

Gradients
- **Luxury gradient** (buttons/headings): orange → red
- **Soft overlay circles**: subtle translucent circles for depth without clutter

### Typography (Modern & Readable)
- Font family: **Outfit** (Google Fonts)
- Display: larger, bold headings for hierarchy
- Body: 14–16px for readability
- Use italic selectively to add elegance (e.g., “culinary desires”)

### Spacing & Radius Rules
- Spacing scale: `8 / 12 / 16 / 24 / 32`
- Corner radius: `16–24` for cards and inputs
- Consistent padding: screen edges use `~24px` horizontal where possible

## 3) Reusable Components (System Thinking)
These patterns appear across screens:
- `LumiereButton`: rounded capsule button with luxury gradient + soft shadow
- `GlassCard`: subtle blur + semi-transparent background to feel premium
- Section titles: consistent font size/weight for scanning
- “Card” style: white background, gentle shadow, rounded corners

## 4) UX & Navigation (User Flow)
**Splash → Authentication → Home (Discover) → Food Detail → Cart**
- **Splash** builds brand emotion instantly and routes after a short delay.
- **Authentication** uses tabs to keep the workflow short and predictable.
- **Home** provides quick discovery tools: search + categories + “Popular” + “Recommended”.
- **Food Detail** supports conversion: customization options + nutrition clarity + fixed CTA.
- **Cart** confirms selection and provides order summary.

## 5) Screen Specs
### 5.1 Splash Screen
**Layout**
- Full-screen soft gradient background
- Centered logo icon + app name (“Lumière Gastronomy”)
- Tagline: **“The Art of Flavor, Curated for Your Senses”**
- Primary CTA button: **“Explore Flavors”**

**UX Decisions**
- Minimal layout reduces cognitive load and sets a premium mood.
- Center alignment makes the brand the first “hero element”.

### 5.2 Authentication Screen
**Layout**
- Header: “Lumière Gastronomy”
- Tab bar: **Login** / **Sign Up**
- Email & password fields (premium rounded input containers)
- Social login buttons:
  - Google
  - Apple
- Primary CTA button: **“Enter the Gallery”**

**UX Decisions**
- Tabs avoid separate pages and shorten time-to-auth.
- Clear CTA placement improves completion rates.

### 5.3 Home Screen (Discover)
**Layout**
- Header text: **“Curating your culinary desires”**
- Search bar (rounded container with search icon)
- Categories row (Burgers, Pizza, Sushi, Desserts)
- Section: **Popular Food** (horizontal scrolling cards)
- Section: **Recommended** (vertical list items)
- Bottom navigation bar (Home / Cart)

**UX Decisions**
- Horizontal list for “Popular” enables fast scanning of images and prices.
- Vertical list for “Recommended” supports deeper reading without overwhelming the user.
- Categories provide structured exploration (less “random browsing”).

### 5.4 Food Detail Screen
**Layout**
- Large food image (hero header)
- Title: **“Miso-Glazed Harvest Bowl”**
- Price + rating
- Description text
- Customization options:
  - Checkbox list (warm, rounded containers)
  - “Clear All” control
- Nutrition info (cards):
  - Calories
  - Protein
- CTA button at bottom:
  - **“Add to Cart”**

**UX Decisions**
- Fixed bottom CTA prevents users from losing the action while scrolling.
- Checkbox list is a clear pattern for multi-select customization.
- Nutrition clarity supports trust and decision-making.

### 5.5 Cart Screen (Flow Requirement)
**Layout**
- Empty state when cart is empty
- Cart items list with quantity controls
- Order summary (subtotal + fees + total)
- Premium primary button for checkout (shown when items exist)

## 6) Color Psychology (Presentation-Ready)
- **Cream**: calm, cleanliness, “museum/gallery” feeling for a premium brand.
- **Orange**: appetite + warmth; draws attention to CTAs and key actions.
- **Red accent**: signals selection and urgency without using harsh neon.
- **Dark gray**: improves readability and keeps the tone sophisticated.

## 7) Accessibility (WCAG-Oriented Notes)
What to include in your presentation:
- **Readable font sizes**: headings larger, body text ~14–16px.
- **Contrast**: dark gray text on cream/white backgrounds for clear legibility.
- **Touch targets**: controls should remain at least ~44px height (buttons/checkbox rows).
- **Semantic controls**: using real checkbox widgets improves screen-reader support.
- **Spacing**: consistent padding reduces accidental taps.

## 8) Mobile Usability
- **SafeArea** prevents UI overlap with status/notch areas.
- **Scroll + fixed CTA** pattern improves conversion on content-heavy screens.
- Bottom navigation stays consistent, minimizing navigation confusion.

## 9) Figma Setup (Ready for Frames)
Suggested device frames:
- iPhone 14 / 15: **390 x 844**

Naming convention:
- `01_Splash`
- `02_Auth_LoginSignUp`
- `03_Home_Discover`
- `04_FoodDetail_MisoGlazedHarvestBowl`
- `05_Cart`

Component styles:
- Button: rounded capsule, gradient fill
- Card: white + soft shadow + radius 16–24
- Input: rounded, subtle border
- Checkbox row: warm highlighted selected state

