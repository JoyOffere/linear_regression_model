# STEMFEM - Female STEM Graduation Prediction

## Mission & Problem Statement
Gender disparity in STEM education remains a global challenge with female graduation rates varying significantly across countries and fields. This project addresses the need for data-driven insights into female STEM participation by developing a machine learning model that predicts female graduation rates based on historical data, enrollment patterns, and gender gap indices. The solution provides policymakers and educators with actionable predictions to improve gender equality in STEM education.

## API Endpoint
**Publicly Available Prediction API:**
- **Model URL:** `https://fem-2sgu.onrender.com/predict` 
- **Method:** POST
- **Swagger UI:** `https://fem-2sgu.onrender.com/docs`

**Request Format:**
```json
{
  "year": 2023,
  "female_enrollment_percentage": 45.5,
  "gender_gap_index": 0.75,
  "country": "United States",
  "stem_field": "Computer Science"
}
```

**Response Format:**
```json
{
  "prediction": 52.3,
  "confidence": 0.85,
  "timestamp": "2025-07-27T10:30:00Z"
}
```

## Video Demo
🎥 **YouTube Demo:** [https://youtu.be/ulkJTqmuuVQ]

## Mobile App Setup Instructions

### Prerequisites
- Flutter SDK 3.32.6+
- Chrome Browser (for web testing)
- Git

### Quick Start
1. **Clone the repository:**
   ```bash
   git clone https://github.com/JoyOffere/linear_regression_model.git
   cd linear_regression_model/stem_prediction_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # Web (Chrome)
   flutter run -d chrome
   
   # Windows Desktop
   flutter run -d windows
   
   # Android (with device connected)
   flutter run -d android
   ```

4. **Access the app:**
   - Web: Automatically opens in Chrome
   - Desktop: Launches as Windows application
   - Mobile: Installs and runs on connected device

### App Features
- **Beautiful UI** with gradient design and animations
- **5 Input Fields:** Year, Female Enrollment %, Gender Gap Index, Country, STEM Field
- **Real-time Predictions** via API integration
- **Form Validation** and error handling
- **Cross-platform** support (Web, Desktop, Mobile)

Mobile

<img width="356" height="600" alt="image" src="https://github.com/user-attachments/assets/0e08dbb2-d28a-4bd0-9147-1ce23d06f40b" />


Desktop

<img width="1102" height="605" alt="image" src="https://github.com/user-attachments/assets/5da49bcb-0899-4417-ac12-3d30d737202b" />


### Troubleshooting
- Ensure API backend is running and accessible
- For web: Allow browser to access the application
- For mobile: Enable developer mode and USB debugging

---
**Built with Flutter | Machine Learning | Data Science**
