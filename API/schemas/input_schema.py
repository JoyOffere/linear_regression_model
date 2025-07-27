from pydantic import BaseModel, Field, validator
from typing import Dict, Any, List
from enum import Enum

class CountryEnum(str, Enum):
    """Enumeration of supported countries"""
    AUSTRALIA = "Australia"
    BRAZIL = "Brazil"
    CANADA = "Canada"
    CHINA = "China"
    FRANCE = "France"
    GERMANY = "Germany"
    INDIA = "India"
    JAPAN = "Japan"
    SOUTH_KOREA = "South Korea"
    UNITED_KINGDOM = "United Kingdom"
    UNITED_STATES = "United States"

class STEMFieldEnum(str, Enum):
    """Enumeration of supported STEM fields"""
    BIOLOGY = "Biology"
    COMPUTER_SCIENCE = "Computer Science"
    ENGINEERING = "Engineering"
    MATHEMATICS = "Mathematics"

class PredictionInput(BaseModel):
    """
    Input schema for STEM graduation rate prediction
    
    This model validates all input parameters with appropriate constraints
    to ensure realistic and valid predictions.
    """
    
    year: int = Field(
        ..., 
        ge=2000, 
        le=2030, 
        description="Year for prediction (2000-2030)",
        example=2024
    )
    
    female_enrollment_percent: float = Field(
        ..., 
        ge=0.0, 
        le=100.0, 
        description="Female enrollment percentage in STEM programs (0-100%)",
        example=45.5
    )
    
    gender_gap_index: float = Field(
        ..., 
        ge=0.0, 
        le=1.0, 
        description="Global Gender Gap Index score (0-1, where 1 indicates perfect equality)",
        example=0.75
    )
    
    country: CountryEnum = Field(
        ..., 
        description="Country name from supported list",
        example=CountryEnum.UNITED_STATES
    )
    
    stem_field: STEMFieldEnum = Field(
        ..., 
        description="STEM field of study",
        example=STEMFieldEnum.COMPUTER_SCIENCE
    )
    
    @validator('female_enrollment_percent')
    def validate_enrollment(cls, v):
        """Validate enrollment percentage"""
        if v < 0 or v > 100:
            raise ValueError('Female enrollment percentage must be between 0 and 100')
        return round(v, 2)
    
    @validator('gender_gap_index')
    def validate_gender_gap(cls, v):
        """Validate gender gap index"""
        if v < 0 or v > 1:
            raise ValueError('Gender Gap Index must be between 0 and 1')
        return round(v, 3)
    
    class Config:
        """Pydantic configuration"""
        use_enum_values = True
        schema_extra = {
            "example": {
                "year": 2024,
                "female_enrollment_percent": 45.5,
                "gender_gap_index": 0.75,
                "country": "United States",
                "stem_field": "Computer Science"
            }
        }

class PredictionOutput(BaseModel):
    """
    Output schema for STEM graduation rate prediction
    """
    
    predicted_graduation_rate: float = Field(
        ..., 
        ge=0.0, 
        le=100.0,
        description="Predicted female graduation rate percentage in STEM"
    )
    
    confidence_score: float = Field(
        default=None,
        ge=0.0,
        le=1.0,
        description="Model confidence score (if available)"
    )
    
    model_used: str = Field(
        ..., 
        description="Name of the machine learning model used for prediction"
    )
    
    input_features: Dict[str, Any] = Field(
        ..., 
        description="Processed input features used by the model"
    )
    
    metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Additional metadata about the prediction"
    )

class HealthResponse(BaseModel):
    """Health check response schema"""
    status: str = Field(..., description="API health status")
    model_loaded: bool = Field(..., description="Whether the ML model is loaded")
    encoders_ready: bool = Field(..., description="Whether encoders are initialized")
    timestamp: str = Field(default=None, description="Response timestamp")

class ErrorResponse(BaseModel):
    """Error response schema"""
    detail: str = Field(..., description="Error message")
    error_code: str = Field(default="PREDICTION_ERROR", description="Error classification")
    suggestions: List[str] = Field(default_factory=list, description="Suggestions to fix the error")

class BatchPredictionInput(BaseModel):
    """Schema for batch predictions"""
    predictions: List[PredictionInput] = Field(
        ..., 
        min_items=1, 
        max_items=100,
        description="List of prediction inputs (max 100)"
    )

class BatchPredictionOutput(BaseModel):
    """Schema for batch prediction results"""
    results: List[PredictionOutput] = Field(..., description="List of prediction results")
    total_predictions: int = Field(..., description="Total number of predictions made")
    successful: int = Field(..., description="Number of successful predictions")
    failed: int = Field(..., description="Number of failed predictions")