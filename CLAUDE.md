# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PetCare AI** (小狗小猫智能养护助手) is an iOS app for pet health management using AI technology. This is a SwiftUI-based iOS application targeting iOS 17.0+ with Core ML integration for AI-powered pet health detection.

**Developer**: Zhuanz (Independent developer with HarmonyOS background, Swift beginner)
**Target Platform**: iOS 17.0+
**Architecture**: MVVM + SwiftUI + SwiftData

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open "PetCare AI.xcodeproj"

# Build for iOS Simulator
xcodebuild -scheme "PetCare AI" -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for device
xcodebuild -scheme "PetCare AI" -destination 'platform=iOS,name=Your Device'

# Clean build
# In Xcode: Cmd + Shift + K
xcodebuild clean -scheme "PetCare AI"
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme "PetCare AI" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -scheme "PetCare AI" -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:PetCareAITests/PetServiceTests/testCreatePet
```

## Current Architecture

### Technology Stack
- **UI Framework**: SwiftUI (primary)
- **Data Persistence**: SwiftData (iOS 17+)
- **Architecture Pattern**: MVVM + Combine
- **AI/ML**: Core ML + Vision Framework
- **Cloud Sync**: CloudKit (planned)
- **Dependencies**: Swift Package Manager

### Current Project Structure
```
PetCare AI/
├── PetCare AI/                    # Main app target
│   ├── PetCare_AIApp.swift       # App entry point with SwiftData setup
│   ├── ContentView.swift         # Main content view (currently template)
│   ├── Item.swift                # SwiftData model (template)
│   ├── Assets.xcassets/          # App icons and assets
│   └── PetCare_AI.entitlements   # App capabilities
├── PetCare AITests/              # Unit tests
├── PetCare AIUITests/            # UI tests
└── 小狗小猫App/                   # Project documentation (Chinese)
    ├── README.md                 # Project overview
    ├── docs/                     # Technical documentation
    ├── design/                   # UI design specs
    └── resources/                # Assets and resources
```

### Planned Architecture (from docs)
```
PetCareApp/
├── Core/                   # Core modules
│   ├── Models/            # Data models (Pet, HealthRecord, Reminder)
│   ├── Services/          # Business services (AI, Notifications, CoreData)
│   ├── Utilities/         # Utility classes
│   └── Extensions/        # Swift extensions
├── Features/              # Feature modules
│   ├── PetProfile/        # Pet profile management
│   ├── HealthRecord/      # Health record tracking
│   ├── AIDetection/       # AI health detection
│   ├── Reminders/         # Smart reminders
│   └── Settings/          # App settings
├── Shared/                # Shared components
│   ├── Views/             # Reusable views
│   ├── Components/        # Custom UI components
│   └── Resources/         # Shared resources
└── App/                   # App entry point
```

## Core Data Models (Planned)

Based on the technical documentation, key SwiftData models to implement:

```swift
@Model
class Pet {
    var id = UUID()
    var name: String = ""
    var breed: String = ""
    var gender: String = ""
    var birthday: Date = Date()
    var weight: Float = 0.0
    var avatarImageData: Data?
    var createdAt = Date()
    var updatedAt = Date()
    
    // Relationships
    var healthRecords: [HealthRecord] = []
    var reminders: [Reminder] = []
    var aiDetectionResults: [AIDetectionResult] = []
}

@Model
class HealthRecord {
    var id = UUID()
    var type: HealthRecordType = .vaccination
    var title: String = ""
    var notes: String = ""
    var date = Date()
    var nextDueDate: Date?
    var imageData: Data?
    
    var pet: Pet?
}
```

## MVP Features (V1.0)

Priority order based on development plan:
1. **Pet Profile Management** - CRUD operations for pet information
2. **Health Records** - Vaccination, checkup, medical history tracking  
3. **Smart Reminders** - Feeding, walking, vaccination reminders using UNUserNotificationCenter
4. **Basic AI Detection** - Core ML + Vision Framework for health issue detection
5. **Local Services** - Location-based vet/pet store recommendations
6. **Data Visualization** - Charts for health trends

## Development Guidelines

### Code Conventions
- Follow Swift naming conventions
- Use MVVM pattern with SwiftUI
- Leverage Combine for reactive programming
- Use SwiftData for persistence (iOS 17+)
- Implement proper error handling with Result types

### Key Technical Decisions
- **SwiftData over Core Data**: Taking advantage of iOS 17+ modern data framework
- **No Backend Initially**: Local-first with CloudKit sync later
- **Core ML**: On-device AI processing for privacy and performance
- **Swift Package Manager**: For dependency management

### Development Phases
The project follows an 8-week development plan:
- Week 1: Environment setup and SwiftUI learning
- Week 2: Core architecture and data models
- Week 3: Pet profile features
- Week 4: Health record management
- Week 5: Reminder system
- Week 6: AI detection integration
- Week 7: UI optimization and polish
- Week 8: Testing and App Store preparation

### Performance Requirements
- App launch: <3 seconds
- AI detection response: <5 seconds
- Memory usage: <150MB
- Crash rate: <1%

## Common Development Tasks

### Adding New SwiftData Models
1. Create model class with `@Model` annotation
2. Add to schema in `PetCare_AIApp.swift`
3. Update ModelContainer configuration
4. Create corresponding ViewModels with `@Query`

### Integrating Core ML
1. Add .mlmodel files to project
2. Use Vision framework for image preprocessing
3. Implement async detection methods
4. Handle results with proper error states

### Local Notifications
1. Request authorization in app startup
2. Use UNUserNotificationCenter for scheduling
3. Handle notification responses in app delegate
4. Manage notification identifiers for updates/cancellation

## Testing Strategy

### Unit Tests
- Focus on business logic in ViewModels and Services
- Mock external dependencies (AI services, location services)
- Test data model relationships and validation

### UI Tests
- Test critical user flows (create pet, add health record)
- Verify navigation and data persistence
- Test AI detection workflow end-to-end

## Build and Deployment

### Requirements
- macOS Sonoma 14.0+
- Xcode 15.0+
- Apple Developer Account
- iOS 17.0+ target devices

### Distribution
- TestFlight for internal testing
- App Store for production release
- Consider staged rollout for AI features