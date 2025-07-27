import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/prediction_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _femaleEnrollmentController = TextEditingController();
  final _genderGapController = TextEditingController();

  String? _selectedCountry;
  String? _selectedSTEMField;

  bool _isLoading = false;
  String? _predictionResult;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample data - replace with your actual options
  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Japan',
    'Australia',
    'Netherlands',
    'Sweden',
    'Norway',
    'Finland',
    'Denmark',
    'Switzerland',
    'Belgium',
    'Austria',
    'South Korea',
    'Singapore',
    'New Zealand',
    'Israel',
    'Ireland',
  ];

  final List<String> _stemFields = [
    'Computer Science',
    'Engineering',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Medicine',
    'Environmental Science',
    'Data Science',
    'Biotechnology',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _yearController.dispose();
    _femaleEnrollmentController.dispose();
    _genderGapController.dispose();
    super.dispose();
  }

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _errorMessage = null;
    });

    try {
      final result = await STEMPredictionService.predictSTEMGraduation(
        year: double.parse(_yearController.text),
        femaleEnrollmentPercentage: double.parse(
          _femaleEnrollmentController.text,
        ),
        genderGapIndex: double.parse(_genderGapController.text),
        country: _selectedCountry!,
        stemField: _selectedSTEMField!,
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          final data = result['data'];
          final prediction = data['prediction'];
          _predictionResult = '${prediction.toStringAsFixed(2)}%';
        } else {
          _errorMessage = result['error'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  void _clearForm() {
    _yearController.clear();
    _femaleEnrollmentController.clear();
    _genderGapController.clear();
    setState(() {
      _selectedCountry = null;
      _selectedSTEMField = null;
      _predictionResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'STEM Prediction',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _clearForm,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Predict Female Graduation Rate',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Enter the required information below',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Input Fields
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 15),

                _buildTextFormField(
                  controller: _yearController,
                  label: 'Year',
                  hint: 'e.g., 2023',
                  icon: Icons.calendar_today,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a year';
                    }
                    final year = double.tryParse(value);
                    if (year == null || year < 1990 || year > 2030) {
                      return 'Please enter a valid year (1990-2030)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _femaleEnrollmentController,
                  label: 'Female Enrollment Percentage',
                  hint: 'e.g., 45.5',
                  icon: Icons.people,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter female enrollment percentage';
                    }
                    final percentage = double.tryParse(value);
                    if (percentage == null ||
                        percentage < 0 ||
                        percentage > 100) {
                      return 'Please enter a valid percentage (0-100)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _genderGapController,
                  label: 'Gender Gap Index',
                  hint: 'e.g., 0.75',
                  icon: Icons.balance,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter gender gap index';
                    }
                    final index = double.tryParse(value);
                    if (index == null || index < 0 || index > 1) {
                      return 'Please enter a valid index (0.0-1.0)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                _buildSectionTitle('Selection'),
                const SizedBox(height: 15),

                _buildDropdownField(
                  value: _selectedCountry,
                  label: 'Country',
                  hint: 'Select a country',
                  icon: Icons.public,
                  items: _countries,
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                _buildDropdownField(
                  value: _selectedSTEMField,
                  label: 'STEM Field',
                  hint: 'Select a STEM field',
                  icon: Icons.biotech,
                  items: _stemFields,
                  onChanged: (value) {
                    setState(() {
                      _selectedSTEMField = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // Predict Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _makePrediction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.psychology, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Predict',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // Results Section
                if (_predictionResult != null) _buildResultCard(),
                if (_errorMessage != null) _buildErrorCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.celebration, color: Colors.white, size: 50),
            const SizedBox(height: 15),
            Text(
              'Prediction Result',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Female Graduation Rate',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _predictionResult!,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF44336), Color(0xFFE53935)],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 50),
            const SizedBox(height: 15),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
