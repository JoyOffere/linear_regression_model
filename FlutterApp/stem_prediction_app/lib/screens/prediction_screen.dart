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
  final PageController _pageController = PageController();

  // Controllers for text inputs
  final _yearController = TextEditingController(text: '2024');
  final _femaleEnrollmentController = TextEditingController(text: '50.0');
  final _genderGapController = TextEditingController(text: '0.7');

  // Selection values
  String? _selectedCountry;
  String? _selectedSTEMField;

  // Slider values
  double _yearSlider = 2024.0;
  double _femaleEnrollmentSlider = 50.0;
  double _genderGapSlider = 0.7;

  // State variables
  bool _isLoading = false;
  String? _predictionResult;
  String? _errorMessage;
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Updated country list matching your Python service
  final List<String> _countries = [
    'Australia',
    'Canada',
    'China',
    'Germany',
    'India',
    'USA',
  ];

  // Updated STEM fields matching your Python service
  final List<String> _stemFields = [
    'Biology',
    'Computer Science',
    'Engineering',
    'Mathematics',
  ];

  // Country flag mapping for visual enhancement
  final Map<String, String> _countryFlags = {
    'Australia': '🇦🇺',
    'Canada': '🇨🇦',
    'China': '🇨🇳',
    'Germany': '🇩🇪',
    'India': '🇮🇳',
    'USA': '🇺🇸',
  };

  // STEM field icons
  final Map<String, IconData> _stemIcons = {
    'Biology': Icons.biotech,
    'Computer Science': Icons.computer,
    'Engineering': Icons.engineering,
    'Mathematics': Icons.calculate,
  };

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

    // Sync controllers with sliders
    _syncControllersWithSliders();
  }

  void _syncControllersWithSliders() {
    _yearController.text = _yearSlider.round().toString();
    _femaleEnrollmentController.text =
        _femaleEnrollmentSlider.toStringAsFixed(1);
    _genderGapController.text = _genderGapSlider.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _yearController.dispose();
    _femaleEnrollmentController.dispose();
    _genderGapController.dispose();
    _pageController.dispose();
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
        year: _yearSlider,
        femaleEnrollmentPercentage: _femaleEnrollmentSlider,
        genderGapIndex: _genderGapSlider,
        country: _selectedCountry!,
        stemField: _selectedSTEMField!,
      );

      setState(() {
        _isLoading = false;
        if (result['success']) {
          final data = result['data'];
          print('Full response data: $data');
          final prediction = data['predicted_graduation_rate'] ?? 0.0;
          try {
            print('Prediction value: $prediction, type: ${prediction.runtimeType}');
            final doublePrediction = (prediction as num).toDouble();
            _predictionResult = '${doublePrediction.toStringAsFixed(2)}%';
            print('Formatted prediction: $_predictionResult');
            // Navigate to results page
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } catch (e, stack) {
            print('Error formatting prediction: $e');
            print(stack);
            _errorMessage = 'Error formatting prediction result.';
          }
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
    _yearSlider = 2024.0;
    _femaleEnrollmentSlider = 50.0;
    _genderGapSlider = 0.7;
    _syncControllersWithSliders();

    setState(() {
      _selectedCountry = null;
      _selectedSTEMField = null;
      _predictionResult = null;
      _errorMessage = null;
    });
  }

  void _goToInputPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _currentPage == 0 ? 'STEM Predictor' : 'Prediction Results',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentPage == 1) {
              _goToInputPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_currentPage == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildInputPage(),
          _buildResultsPage(),
        ],
      ),
    );
  }

  Widget _buildInputPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 25),

              // Year Section
              _buildSectionTitle('📅 Year Selection'),
              const SizedBox(height: 15),
              _buildYearSlider(),
              const SizedBox(height: 25),

              // Country Section
              _buildSectionTitle('🌍 Country Selection'),
              const SizedBox(height: 15),
              _buildCountryGrid(),
              const SizedBox(height: 25),

              // STEM Field Section
              _buildSectionTitle('🔬 STEM Field'),
              const SizedBox(height: 15),
              _buildSTEMFieldCards(),
              const SizedBox(height: 25),

              // Female Enrollment Section
              _buildSectionTitle('👩‍🎓 Female Enrollment'),
              const SizedBox(height: 15),
              _buildFemaleEnrollmentSlider(),
              const SizedBox(height: 25),

              // Gender Gap Index Section
              _buildSectionTitle('⚖️ Gender Gap Index'),
              const SizedBox(height: 15),
              _buildGenderGapSlider(),
              const SizedBox(height: 30),

              // Predict Button
              _buildPredictButton(),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage != null) _buildErrorCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (_predictionResult != null) _buildResultCard(),
          const SizedBox(height: 30),
          _buildSummaryCard(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
              child: const Icon(Icons.analytics, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEM Graduation Predictor',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Predict female graduation rates in STEM fields',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildYearSlider() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Year: ${_yearSlider.round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                Text(
                  '2000 - 2030',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Slider(
              value: _yearSlider,
              min: 2000,
              max: 2030,
              divisions: 30,
              activeColor: const Color(0xFF1E88E5),
              onChanged: (value) {
                setState(() {
                  _yearSlider = value;
                  _yearController.text = value.round().toString();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: _countries.map((country) {
            final isSelected = _selectedCountry == country;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF1E88E5) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _countryFlags[country] ?? '🏳️',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          country,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSTEMFieldCards() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: _stemFields.map((field) {
            final isSelected = _selectedSTEMField == field;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSTEMField = field;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF1E88E5) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _stemIcons[field],
                        color:
                            isSelected ? Colors.white : const Color(0xFF1E88E5),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          field,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFemaleEnrollmentSlider() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrollment: ${_femaleEnrollmentSlider.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                Text(
                  '0% - 100%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Slider(
              value: _femaleEnrollmentSlider,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              activeColor: const Color(0xFF009688),
              onChanged: (value) {
                setState(() {
                  _femaleEnrollmentSlider = value;
                  _femaleEnrollmentController.text = value.toStringAsFixed(1);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderGapSlider() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Index: ${_genderGapSlider.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                Text(
                  '0.0 - 1.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Higher values indicate better gender equality',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            Slider(
              value: _genderGapSlider,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              activeColor: const Color(0xFFFF9800),
              onChanged: (value) {
                setState(() {
                  _genderGapSlider = value;
                  _genderGapController.text = value.toStringAsFixed(2);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictButton() {
    final bool canPredict =
        _selectedCountry != null && _selectedSTEMField != null;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canPredict && !_isLoading ? _makePrediction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.blue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBackgroundColor: Colors.grey[300],
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
                    canPredict
                        ? 'Predict Graduation Rate'
                        : 'Select Country & Field',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  const Icon(Icons.celebration, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Prediction Result',
              style: GoogleFonts.poppins(
                fontSize: 22,
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
            const SizedBox(height: 15),
            Text(
              _predictionResult ?? '0%',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: (_predictionResult != null
                    ? double.parse(_predictionResult!.replaceAll('%', '')) / 100
                    : 0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Summary',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 15),
            _buildSummaryRow('Year', '${_yearSlider.round()}'),
            _buildSummaryRow('Country', _selectedCountry ?? 'Not selected'),
            _buildSummaryRow(
                'STEM Field', _selectedSTEMField ?? 'Not selected'),
            _buildSummaryRow('Female Enrollment',
                '${_femaleEnrollmentSlider.toStringAsFixed(1)}%'),
            _buildSummaryRow(
                'Gender Gap Index', _genderGapSlider.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _goToInputPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Make Another Prediction',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
              side: const BorderSide(color: Color(0xFF1E88E5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home),
                const SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
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
