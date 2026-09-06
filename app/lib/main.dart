import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NexaForgeApp());
}

class NexaForgeApp extends StatelessWidget {
  const NexaForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaCalc',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF3D00),
          surface: Color(0xFF161823),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculationItem {
  final String expression;
  final String result;

  CalculationItem({required this.expression, required this.result});
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  final List<CalculationItem> _history = [];
  bool _isEvaluated = false;

  void _onButtonPressed(String label) {
    HapticFeedback.lightImpact();

    setState(() {
      if (label == 'AC') {
        _expression = '';
        _result = '0';
        _isEvaluated = false;
        return;
      }

      if (label == '⌫') {
        if (_isEvaluated) {
          _expression = '';
          _result = '0';
          _isEvaluated = false;
          return;
        }
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _calculateLiveResult();
        }
        return;
      }

      if (label == '=') {
        if (_expression.isEmpty) return;
        _calculateFinalResult();
        return;
      }

      if (_isEvaluated) {
        if (_isOperator(label)) {
          _expression = _result + label;
        } else {
          _expression = label;
        }
        _isEvaluated = false;
        _calculateLiveResult();
        return;
      }

      // Handle duplicate operators or leading operators
      if (_isOperator(label)) {
        if (_expression.isEmpty) {
          if (label == '-') {
            _expression = label;
          }
          return;
        }
        String lastChar = _expression[_expression.length - 1];
        if (_isOperator(lastChar)) {
          _expression = _expression.substring(0, _expression.length - 1) + label;
          return;
        }
      }

      // Handle percentage
      if (label == '%') {
        _handlePercentage();
        return;
      }

      // Handle plus/minus toggle
      if (label == '+/-') {
        _handlePlusMinus();
        return;
      }

      _expression += label;
      _calculateLiveResult();
    });
  }

  bool _isOperator(String label) {
    return label == '+' || label == '-' || label == '×' || label == '÷';
  }

  void _handlePercentage() {
    if (_expression.isEmpty) return;
    try {
      double val = _evaluateMath(_expression);
      double res = val / 100.0;
      _result = _formatResult(res);
      _expression = _result;
      _isEvaluated = true;
    } catch (_) {}
  }

  void _handlePlusMinus() {
    if (_expression.isEmpty) return;
    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }
    _calculateLiveResult();
  }

  void _calculateLiveResult() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    try {
      // Evaluate only if expression ends with number
      String last = _expression[_expression.length - 1];
      if (!_isOperator(last) && last != '.') {
        double val = _evaluateMath(_expression);
        _result = _formatResult(val);
      }
    } catch (_) {
      // Ignore intermediate syntax errors
    }
  }

  void _calculateFinalResult() {
    try {
      double val = _evaluateMath(_expression);
      String formattedResult = _formatResult(val);
      _history.insert(
        0,
        CalculationItem(expression: _expression, result: formattedResult),
      );
      _result = formattedResult;
      _isEvaluated = true;
    } catch (_) {
      _result = 'Error';
    }
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    String str = value.toStringAsFixed(6);
    // Trim trailing zeros
    str = str.replaceAll(RegExp(r'0+$'), '');
    str = str.replaceAll(RegExp(r'\.$'), '');
    return str;
  }

  double _evaluateMath(String expr) {
    String sanitized = expr.replaceAll('×', '*').replaceAll('÷', '/');
    List<String> tokens = _tokenize(sanitized);
    return _parseTokens(tokens);
  }

  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    String numberBuffer = '';
    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if ('0123456789.'.contains(char)) {
        numberBuffer += char;
      } else if ('+-*/'.contains(char)) {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer);
          numberBuffer = '';
        }
        if (char == '-' && (tokens.isEmpty || '+-*/'.contains(tokens.last))) {
          numberBuffer += '-';
        } else {
          tokens.add(char);
        }
      }
    }
    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer);
    }
    return tokens;
  }

  double _parseTokens(List<String> tokens) {
    if (tokens.isEmpty) return 0;

    // First pass: Multiplication and Division
    List<String> pass1 = [];
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        if (pass1.isEmpty || i + 1 >= tokens.length) throw Exception();
        String op = tokens[i];
        double prev = double.parse(pass1.removeLast());
        double next = double.parse(tokens[i + 1]);
        double res = op == '*' ? prev * next : prev / next;
        pass1.add(res.toString());
        i += 2;
      } else {
        pass1.add(tokens[i]);
        i++;
      }
    }

    // Second pass: Addition and Subtraction
    if (pass1.isEmpty) return 0;
    double result = double.parse(pass1[0]);
    int j = 1;
    while (j < pass1.length) {
      if (j + 1 >= pass1.length) break;
      String op = pass1[j];
      double next = double.parse(pass1[j + 1]);
      if (op == '+') result += next;
      if (op == '-') result -= next;
      j += 2;
    }
    return result;
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161823),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calculation History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_history.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        setState(() => _history.clear());
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.expression,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '= ${item.result}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _expression = item.expression;
                                _result = item.result;
                                _isEvaluated = true;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 20),
            SizedBox(width: 8),
            Text(
              'NexaCalc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            onPressed: _showHistoryModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? ' ' : _expression,
                        style: TextStyle(
                          fontSize: 28,
                          color: _isEvaluated ? Colors.white38 : Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: _isEvaluated ? 56 : 44,
                        fontWeight: FontWeight.bold,
                        color: _isEvaluated
                            ? const Color(0xFF00E5FF)
                            : Colors.white,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(_result),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Keypad Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF131520),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButtonRow(['AC', '+/-', '%', '÷']),
                    _buildButtonRow(['7', '8', '9', '×']),
                    _buildButtonRow(['4', '5', '6', '-']),
                    _buildButtonRow(['1', '2', '3', '+']),
                    _buildButtonRow(['0', '.', '⌫', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.map((label) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: _buildCalcButton(label),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalcButton(String label) {
    bool isOperator = _isOperator(label);
    bool isEquals = label == '=';
    bool isAction = label == 'AC' || label == '+/-' || label == '%' || label == '⌫';

    Color bgColor;
    Color textColor;

    if (isEquals) {
      bgColor = const Color(0xFFFF3D00);
      textColor = Colors.white;
    } else if (isOperator) {
      bgColor = const Color(0xFF1E2235);
      textColor = const Color(0xFF00E5FF);
    } else if (isAction) {
      bgColor = const Color(0xFF1A1C29);
      textColor = const Color(0xFFFFAB00);
    } else {
      bgColor = const Color(0xFF1E2130);
      textColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onButtonPressed(label),
        borderRadius: BorderRadius.circular(22),
        splashColor: textColor.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isEquals
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: isOperator || isEquals || isAction
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}