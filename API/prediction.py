import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder, StandardScaler
from typing import Dict, Any, Optional, Tuple
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class STEMPredictionService:
    """
    Service class for handling STEM graduation rate predictions
    """
    
    def __init__(self, model_path: str = "model/best_model.pkl"):
        """
        Initialize the prediction service
        
        Args:
            model_path: Path to the saved model file
        """
        self.model_path = model_path
        self.model = None
        self.scaler = None
        self.country_encoder = None
        self.field_encoder = None
        
        # Predefined categories (should match training data)
        self.countries = [
            "Australia", "Canada", "China",
            "Germany", "India", "USA"
        ]
        
        self.stem_fields = [
            "Biology", "Computer Science", "Engineering", "Mathematics"
        ]
        
        self.feature_names = [
            'Year', 'Female Enrollment (%)', 'Gender Gap Index', 
            'Country_encoded', 'STEM_field_encoded'
        ]
        
        # Load model and initialize encoders
        self._load_model()
        self._initialize_encoders()
    
    def _load_model(self) -> None:
        """Load the trained machine learning model"""
        try:
            if os.path.exists(self.model_path):
                self.model = joblib.load(self.model_path)
                logger.info(f"Model loaded successfully from {self.model_path}")
            else:
                logger.error(f"Model file not found at {self.model_path}")
                raise FileNotFoundError(f"Model file not found: {self.model_path}")
        except Exception as e:
            logger.error(f"Error loading model: {e}")
            raise e
    
    def _initialize_encoders(self) -> None:
        """Initialize label encoders and scaler"""
        try:
            # Initialize country encoder
            self.country_encoder = LabelEncoder()
            self.country_encoder.fit(self.countries)
            
            # Initialize STEM field encoder
            self.field_encoder = LabelEncoder()
            self.field_encoder.fit(self.stem_fields)
            
            # Initialize scaler with approximate statistics
            # In production, these should be saved from training
            self.scaler = StandardScaler()
            self.scaler.mean_ = np.array([2018.0, 50.0, 0.7, 5.0, 1.5])
            self.scaler.scale_ = np.array([5.0, 15.0, 0.15, 3.0, 1.2])
            
            logger.info("Encoders and scaler initialized successfully")
            
        except Exception as e:
            logger.error(f"Error initializing encoders: {e}")
            raise e
    
    def validate_input(self, year: int, female_enrollment: float, 
                      gender_gap_index: float, country: str, 
                      stem_field: str) -> Tuple[bool, str]:
        """
        Validate input parameters
        
        Returns:
            Tuple of (is_valid, error_message)
        """
        # Validate year
        if not (2000 <= year <= 2030):
            return False, "Year must be between 2000 and 2030"
        
        # Validate enrollment percentage
        if not (0.0 <= female_enrollment <= 100.0):
            return False, "Female enrollment percentage must be between 0 and 100"
        
        # Validate gender gap index
        if not (0.0 <= gender_gap_index <= 1.0):
            return False, "Gender Gap Index must be between 0 and 1"
        
        # Validate country
        if country not in self.countries:
            return False, f"Country '{country}' not supported. Available: {self.countries}"
        
        # Validate STEM field
        if stem_field not in self.stem_fields:
            return False, f"STEM field '{stem_field}' not supported. Available: {self.stem_fields}"
        
        return True, ""
    
    def preprocess_input(self, year: int, female_enrollment: float,
                        gender_gap_index: float, country: str,
                        stem_field: str) -> np.ndarray:
        """
        Preprocess input data for model prediction
        
        Returns:
            Processed and scaled feature array
        """
        # Encode categorical variables
        country_encoded = self.country_encoder.transform([country])[0]
        field_encoded = self.field_encoder.transform([stem_field])[0]
        
        # Create feature array
        features = np.array([[
            year,
            female_enrollment,
            gender_gap_index,
            country_encoded,
            field_encoded
        ]])
        
        # Scale features
        features_scaled = self.scaler.transform(features)
        
        return features_scaled, country_encoded, field_encoded
    
    def predict(self, year: int, female_enrollment: float,
                gender_gap_index: float, country: str,
                stem_field: str) -> Dict[str, Any]:
        """
        Make a prediction for female graduation rate in STEM
        
        Returns:
            Dictionary containing prediction results
        """
        # Validate input
        is_valid, error_msg = self.validate_input(
            year, female_enrollment, gender_gap_index, country, stem_field
        )
        
        if not is_valid:
            raise ValueError(error_msg)
        
        # Preprocess input
        features_scaled, country_encoded, field_encoded = self.preprocess_input(
            year, female_enrollment, gender_gap_index, country, stem_field
        )
        
        # Make prediction
        prediction = self.model.predict(features_scaled)[0]
        
        # Ensure prediction is within realistic bounds
        prediction = max(0.0, min(100.0, prediction))
        
        # Prepare result
        result = {
            "predicted_graduation_rate": round(prediction, 2),
            "model_used": "SGD Regressor",  # Update based on your best model
            "input_features": {
                "year": year,
                "female_enrollment_percent": female_enrollment,
                "gender_gap_index": gender_gap_index,
                "country": country,
                "stem_field": stem_field,
                "country_encoded": int(country_encoded),
                "stem_field_encoded": int(field_encoded)
            },
            "metadata": {
                "prediction_timestamp": datetime.utcnow().isoformat(),
                "model_version": "1.0.0",
                "feature_names": self.feature_names
            }
        }
        
        return result
    
    def get_feature_importance(self) -> Optional[Dict[str, float]]:
        """
        Get feature importance if available from the model
        
        Returns:
            Dictionary of feature importances or None
        """
        try:
            if hasattr(self.model, 'feature_importances_'):
                importances = self.model.feature_importances_
                return dict(zip(self.feature_names, importances))
            elif hasattr(self.model, 'coef_'):
                # For linear models, use absolute coefficients as importance
                coefficients = np.abs(self.model.coef_)
                return dict(zip(self.feature_names, coefficients))
            else:
                return None
        except Exception as e:
            logger.warning(f"Could not extract feature importance: {e}")
            return None
    
    def health_check(self) -> Dict[str, Any]:
        """
        Check the health status of the prediction service
        
        Returns:
            Dictionary containing health status information
        """
        return {
            "model_loaded": self.model is not None,
            "encoders_ready": all([
                self.country_encoder is not None,
                self.field_encoder is not None,
                self.scaler is not None
            ]),
            "supported_countries": len(self.countries),
            "supported_stem_fields": len(self.stem_fields),
            "model_type": type(self.model).__name__ if self.model else None,
            "timestamp": datetime.utcnow().isoformat()
        }

# Global instance of the prediction service
prediction_service = STEMPredictionService()