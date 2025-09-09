import 'package:flutter/material.dart';

// Sticky Top Banner 

OverlayEntry? _activeTopBanner;

void _showTopBanner(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  // Remove any existing banner
  _activeTopBanner?.remove();
  _activeTopBanner = null;

  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final entry = OverlayEntry(
    builder: (ctx) => _TopStickyBanner(
      message: message,
      onClose: () {
        final OverlayEntry? entry = _activeTopBanner;
        if (_activeTopBanner == entry) {
          _activeTopBanner?.remove();
          _activeTopBanner = null;
        }
      },
      duration: duration,
    ),
  );

  overlay.insert(entry);
  _activeTopBanner = entry;
}

class _TopStickyBanner extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final Duration duration;

  const _TopStickyBanner({
    Key? key,
    required this.message,
    required this.onClose,
    required this.duration,
  }) : super(key: key);

  @override
  State<_TopStickyBanner> createState() => _TopStickyBannerState();
}

class _TopStickyBannerState extends State<_TopStickyBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0, -1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ac.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ac.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top; 
    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _offset,
            child: Padding(
              padding: EdgeInsets.only(top: topInset > 0 ? 8 : 16, left: 16, right: 16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.black26,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Layouts

InputDecoration _inputDec({
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF005CE7), width: 1.5),
    ),
  );
}

RoundedRectangleBorder get _sheetShape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    );

Widget _handle() => Container(
      width: 48,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );

// Forgot Password - Step 1
class ForgotPasswordEmailModal extends StatefulWidget {
  const ForgotPasswordEmailModal({super.key});
  @override
  State<ForgotPasswordEmailModal> createState() =>
      _ForgotPasswordEmailModalState();
}

class _ForgotPasswordEmailModalState extends State<ForgotPasswordEmailModal> {
  final _emailCtrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final value = _emailCtrl.text.trim();
    final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    if (!isValid) {
      setState(() => _err = 'Please enter a valid email');
      _showTopBanner(context, 'Please enter a valid email');
      return;
    }
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: _sheetShape,
      builder: (_) => ForgotPasswordCodeModal(email: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const Text(
              "Forgot Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "A verification code will be sent to your email to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDec(
                label: "Email",
                hint: "you@example.com",
                prefixIcon: const Icon(Icons.mail),
                suffixIcon: _emailCtrl.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(_emailCtrl.clear),
                        ),
                      )
                    : null,
              ).copyWith(errorText: _err),
              onChanged: (_) => setState(() => _err = null),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _next,
                child: const Text(
                  "Send Verification Code",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Forgot Password - Step 2
class ForgotPasswordCodeModal extends StatefulWidget {
  final String email;
  const ForgotPasswordCodeModal({super.key, required this.email});
  @override
  State<ForgotPasswordCodeModal> createState() =>
      _ForgotPasswordCodeModalState();
}

class _ForgotPasswordCodeModalState extends State<ForgotPasswordCodeModal> {
  final _nodes = List.generate(6, (_) => FocusNode());
  final _ctrs = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    for (final c in _ctrs) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.length == 1 && i < 5) _nodes[i + 1].requestFocus();
    if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
    setState(() {}); 
  }

  void _submit() {
    final code = _ctrs.map((c) => c.text).join();
    if (code.length != 6) {
      _showTopBanner(context, 'Please enter the 6-digit code');
      return;
    }
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: _sheetShape,
      builder: (_) => const ForgotPasswordNewPassModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const Text(
              "Enter Verification Code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "We sent a code to ${widget.email}.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6), 
                  child: SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _ctrs[i],
                      focusNode: _nodes[i],
                      autofocus: i == 0,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (v) => _onChanged(
                        i,
                        v.replaceAll(RegExp(r'[^0-9]'), ''),
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: Trigger resend via API
                _showTopBanner(context, 'Verification code resent');
              },
              child: const Text("Resend code"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Forgot Password - Step 3 New Password
class ForgotPasswordNewPassModal extends StatefulWidget {
  const ForgotPasswordNewPassModal({super.key});
  @override
  State<ForgotPasswordNewPassModal> createState() =>
      _ForgotPasswordNewPassModalState();
}

class _ForgotPasswordNewPassModalState
    extends State<ForgotPasswordNewPassModal> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_pass.text.isEmpty || _confirm.text.isEmpty) {
      _showTopBanner(context, 'Please enter and confirm your password');
      return;
    }
    if (_pass.text != _confirm.text) {
      _showTopBanner(context, 'Passwords do not match');
      return;
    }
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: _sheetShape,
      builder: (_) => const ForgotPasswordSuccessModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const Text(
              "Set a New Password",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: !_showPass,
              decoration: _inputDec(
                label: "Password",
                hint: "Input Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      _showPass ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: !_showConfirm,
              decoration: _inputDec(
                label: "Confirm Password",
                hint: "Re-enter your password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      _showConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Forgot Password - Step 4 Success
class ForgotPasswordSuccessModal extends StatelessWidget {
  const ForgotPasswordSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 48, color: Color(0xFF22C55E)),
            SizedBox(height: 8),
            Text(
              "Password Successfully Updated",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Your account password has been updated. Please use your email and new password to sign in.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
