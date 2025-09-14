import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

// Input Field 
class InputField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  /// External error message (drives red border + our custom caption)
  final String? errorText;

  /// Optional input formatters (e.g. for numbers only, uppercase, etc.)
  final List<TextInputFormatter>? inputFormatters;

  // ---- Styles & helpers ----
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475467),
  );

  static const _hintStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF98A2B3),
  );

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.inputFormatters, // now optional
  });

  @override
  Widget build(BuildContext context) {
    final bool hasExternalError =
        errorText != null && errorText!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _titleStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            inputFormatters: inputFormatters, // forwarded if provided
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF101828),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: _hintStyle,
              isDense: true,

              // Trigger red border (error state) without showing Flutter's error label
              errorText: hasExternalError ? '' : null,
              errorStyle: const TextStyle(
                fontSize: 0,
                height: 0, // hide internal error label completely
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF475467)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF475467)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF005CE7),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD92D20),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD92D20),
                  width: 1.5,
                ),
              ),

              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),

            // Keep built-in validator available for Form flows.
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return ''; // just trigger red border
                    }
                    return null;
                  }
                : null,
          ),

          // Our custom caption, exactly 4px below the field border
          if (hasExternalError) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD92D20),
                height: 1.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Attachment
class FileAttachmentPicker extends StatefulWidget {
  final String label;
  final bool isRequired;
  final void Function(List<PlatformFile>)? onChanged;

  const FileAttachmentPicker({
    super.key,
    required this.label,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  State<FileAttachmentPicker> createState() => _FileAttachmentPickerState();
}

class _FileAttachmentPickerState extends State<FileAttachmentPicker> {
  List<PlatformFile> _selectedFiles = [];

  // ---- Styles & helpers ----
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475467),
  );

  static const _hintStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF98A2B3),
  );

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(result.files));
      widget.onChanged?.call(_selectedFiles);
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
    widget.onChanged?.call(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: _titleStyle),
          const SizedBox(height: 8),

          // Attach area
          SizedBox(
            width: double.infinity,
            height: 100,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _pickFiles,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF005CE8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 20,
                        color: Color(0xFF005CE8),
                      ),
                      const SizedBox(width: 8),
                      Text('Attach files', style: _hintStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Selected files (chips)
          if (_selectedFiles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Chip(
                      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: const Color(0xFFF6F7F9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text(
                        file.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF344054),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeFile(index),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}

// Multiple Contractor Name
class MultiContractorInputField extends StatefulWidget {
  final bool isRequired;
  final void Function(List<Map<String, String>>) onChanged;

  const MultiContractorInputField({
    super.key,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  State<MultiContractorInputField> createState() =>
      _MultiContractorInputFieldState();
}

class _MultiContractorInputFieldState extends State<MultiContractorInputField> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final List<Map<String, String>> _contractors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _addContractor() {
    final name = _nameController.text.trim();
    final company = _companyController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty || company.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required.')));
      return;
    }

    setState(() {
      _contractors.add({'name': name, 'company': company, 'contact': contact});
      _nameController.clear();
      _companyController.clear();
      _contactController.clear();
    });

    widget.onChanged(List<Map<String, String>>.from(_contractors));
  }

  void _removeContractor(int index) {
    setState(() {
      _contractors.removeAt(index);
    });
    widget.onChanged(List<Map<String, String>>.from(_contractors));
  }

  // ---- Styles (mirrors InputField) ----
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475467),
  );

  static const _hintStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF98A2B3),
  );

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _hintStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475467)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475467)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF005CE7), // primary blue
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _fieldBlock({
    required String title,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF101828), // standard dark text
          ),
          decoration: _inputDecoration(
            hint,
          ).copyWith(prefixIcon: prefixIcon, suffixIcon: suffixIcon),
          // keep validation behavior via snackbar (unchanged)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldBlock(
            title: 'Full Name',
            controller: _nameController,
            hint: 'e.g., Juan Dela Cruz',
          ),
          const SizedBox(height: 12),

          _fieldBlock(
            title: 'Company',
            controller: _companyController,
            hint: 'e.g., ABC Services',
          ),
          const SizedBox(height: 12),

          _fieldBlock(
            title: 'Contact Number',
            controller: _contactController,
            hint: 'e.g., +63 917 555 1234',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Add button — tuned colors to your InputField palette
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _addContractor,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Contractor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF005CE7),
                side: const BorderSide(color: Color(0xFF475467)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chips list — slight polish to match your neutral palette
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _contractors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final c = entry.value;
                  return Chip(
                    label: Text(
                      '${c['name']} - ${c['contact']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF344054),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFF2F4F7),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteIconColor: const Color(0xFF667085),
                    shape: StadiumBorder(
                      side: const BorderSide(color: Color(0xFFE4E7EC)),
                    ),
                    onDeleted: () => _removeContractor(index),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// Dropdown field
class DropdownField<T> extends StatefulWidget {
  final String label;

  // Single-select
  final T? value;
  final void Function(T?)? onChanged;

  // Multi-select
  final bool isMultiSelect;
  final List<T>? selectedValues;
  final void Function(List<T>)? onMultiChanged;

  final List<T> items;

  // Validation
  final bool isRequired;
  final String? requiredMessage; // message shown under the field when invalid

  // UI
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Inline "Others" text field controller (shown when selection equals 'Others')
  final TextEditingController? otherController;

  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    // single
    this.value,
    this.onChanged,
    // multi
    this.isMultiSelect = false,
    this.selectedValues,
    this.onMultiChanged,
    // validation
    this.isRequired = false,
    this.requiredMessage,
    // ui
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    // others
    this.otherController,
  });

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  bool _showOtherInput = false;
  late final TextEditingController _multiDisplayCtrl;

  // ---- Styles ----
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475467),
  );
  static const _hintStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF98A2B3),
  );
  static const _valueStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF101828),
  );
  static const _itemStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: Color(0xFF475467),
  );

  bool _isOthers(dynamic v) =>
      v != null && v.toString().trim().toLowerCase() == 'others';

  String _joinValues(List<T>? list) =>
      (list == null || list.isEmpty) ? '' : list.map((e) => e.toString()).join(', ');

  InputDecoration _decoration({
    required String? hintText,
    required Widget? prefixIcon,
    required Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: _hintStyle,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475467)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475467)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF005CE7), width: 1.5),
      ),
      // Red when invalid and not focused:
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD92D20), width: 1.5),
      ),
      // Keep blue when focused even if invalid:
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF005CE7), width: 1.5),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  @override
  void initState() {
    super.initState();
    _multiDisplayCtrl = TextEditingController(
      text: _joinValues(widget.selectedValues),
    );
    _showOtherInput = widget.isMultiSelect
        ? (widget.selectedValues ?? const []).any(_isOthers)
        : _isOthers(widget.value);
  }

  @override
  void didUpdateWidget(covariant DropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMultiSelect && widget.selectedValues != oldWidget.selectedValues) {
      _multiDisplayCtrl.text = _joinValues(widget.selectedValues);
      _showOtherInput = (widget.selectedValues ?? const []).any(_isOthers);
    }
    if (!widget.isMultiSelect && widget.value != oldWidget.value) {
      _showOtherInput = _isOthers(widget.value);
    }
  }

  @override
  void dispose() {
    _multiDisplayCtrl.dispose();
    super.dispose();
  }

  Future<List<T>?> _openMultiDialog(List<T> seed) async {
    final selected = seed.toSet();

    return showDialog<List<T>>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 440, maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: _titleStyle),
                const SizedBox(height: 8),
                Expanded(
                  child: Scrollbar(
                    child: StatefulBuilder(
                      builder: (ctx, setInner) => ListView.builder(
                        itemCount: widget.items.length,
                        itemBuilder: (_, i) {
                          final item = widget.items[i];
                          final checked = selected.contains(item);
                          return CheckboxListTile(
                            value: checked,
                            onChanged: (v) {
                              setInner(() {
                                if (v == true) {
                                  selected.add(item);
                                } else {
                                  selected.remove(item);
                                }
                              });
                            },
                            dense: true,
                            title: Text(item.toString(), style: _itemStyle),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, selected.toList()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005CE7),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.hintText ?? 'Select ${widget.label}...';

    // We hide Flutter's built-in error text and render our own below.
    // Non-null validator (' ') triggers the error border visually.
    String? _requiredValidator(Object? val, {bool isMulti = false}) {
      if (!widget.isRequired) return null;
      if (isMulti) {
        final list = widget.selectedValues ?? const [];
        return list.isEmpty ? ' ' : null;
      } else {
        return val == null ? ' ' : null;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (NO ASTERISK)
          Text(widget.label, style: _titleStyle),
          const SizedBox(height: 8),

          // ===== SINGLE-SELECT =====
          if (!widget.isMultiSelect)
            DropdownButtonFormField<T>(
              value: widget.value,
              isExpanded: true,
              isDense: false,
              alignment: AlignmentDirectional.centerStart,
              menuMaxHeight: 320,
              style: _valueStyle,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475467)),
              dropdownColor: Colors.white,
              autovalidateMode: AutovalidateMode.always,
              items: widget.items
                  .map((item) =>
                      DropdownMenuItem<T>(value: item, child: Text(item.toString(), style: _itemStyle)))
                  .toList(),
              onChanged: (val) {
                setState(() => _showOtherInput = _isOthers(val));
                widget.onChanged?.call(val);
              },
              validator: (val) => _requiredValidator(val),
              decoration: _decoration(
                hintText: hint,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
              ).copyWith(
                errorStyle: const TextStyle(fontSize: 0, height: 0), // hide default helper
              ),
            ),

          // ===== MULTI-SELECT (read-only shell that opens a dialog) =====
          if (widget.isMultiSelect)
            TextFormField(
              readOnly: true,
              controller: _multiDisplayCtrl,
              style: _valueStyle,
              autovalidateMode: AutovalidateMode.always,
              decoration: _decoration(
                hintText: hint,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon ??
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF475467)),
              ).copyWith(
                errorStyle: const TextStyle(fontSize: 0, height: 0),
              ),
              validator: (_) => _requiredValidator(null, isMulti: true),
              onTap: () async {
                final seed = List<T>.from(widget.selectedValues ?? const []);
                final res = await _openMultiDialog(seed);
                if (res != null) {
                  _multiDisplayCtrl.text = _joinValues(res);
                  setState(() => _showOtherInput = res.any(_isOthers));
                  widget.onMultiChanged?.call(res);
                }
              },
            ),

          // ===== “Others” inline input (only when needed) =====
          if (_showOtherInput && widget.otherController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.otherController,
              style: _valueStyle,
              autovalidateMode: AutovalidateMode.always,
              decoration: _decoration(
                hintText: 'Please specify',
                prefixIcon: null,
                suffixIcon: null,
              ).copyWith(
                errorStyle: const TextStyle(fontSize: 0, height: 0),
              ),
              validator: (v) {
                // If "Others" is chosen, require some text
                if (_showOtherInput && (v == null || v.trim().isEmpty)) {
                  return ' ';
                }
                return null;
              },
            ),
          ],

          // ===== Custom error caption (only when invalid) =====
          Builder(
            builder: (context) {
              final formFieldState = Form.of(context);
              // We compute invalid state by running the same condition again:
              final isInvalid = widget.isRequired &&
                  ((widget.isMultiSelect
                          ? ((widget.selectedValues ?? const []).isEmpty)
                          : widget.value == null) ||
                      (_showOtherInput && widget.otherController != null && (widget.otherController!.text.trim().isEmpty)));

              if (!isInvalid) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.requiredMessage ?? '${widget.label} is required.',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD92D20),
                    height: 1.0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Pin to dashboard toggle button
class PinToDashboardTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PinToDashboardTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _brand = Color(0xFF005CE7);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Container(
          // No border, no shadow — soft surface only
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading icon chip (no border, no shadow)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.push_pin_outlined,
                  size: 20,
                  color: _brand,
                ),
              ),
              const SizedBox(width: 12),

              // Title + subtitle
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pin to Dashboard',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Show this announcement on Home',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),

              // Brand-blue toggle (no shadow needed)
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                // Material: thumb = activeColor, track = activeTrackColor
                // iOS:     track = activeTrackColor
                activeColor:
                    Colors.white, // white thumb looks cleaner on brand track
                activeTrackColor: _brand, // brand-blue track
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Checklist Design

// === Styles you can reuse ===
const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);
const _brand = Color(0xFF005CE7);
const _stroke = Color(0xFFD0D5DD);
const _panel = Color(0xFFF9FAFB);

/// A tiny numbered chip for each row
class _IndexChip extends StatelessWidget {
  final int index;
  const _IndexChip(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _brand,
        ),
      ),
    );
  }
}

// Deelete Button
class _GhostDeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GhostDeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
      ),
    );
  }
}

// Task Checklist ---------------------------------
class ChecklistSection extends StatelessWidget {
  final List<TextEditingController> checklistControllers;
  final VoidCallback addChecklistItem;
  final void Function(int) removeChecklistItem;

  const ChecklistSection({
    super.key,
    required this.checklistControllers,
    required this.addChecklistItem,
    required this.removeChecklistItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + Add button on the right
        Row(
          children: [
            const Expanded(
              child: Text(
                'Task Checklist',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: addChecklistItem,
              icon: const Icon(Icons.add, size: 18, color: _brand),
              label: const Text(
                'Add item',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _brand,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                foregroundColor: _brand,
                splashFactory: InkRipple.splashFactory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Plain list
        Column(
          children: List.generate(checklistControllers.length, (index) {
            final c = checklistControllers[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == checklistControllers.length - 1 ? 0 : 8,
              ),
              child: InputField(
                label: 'Item ${index + 1}',
                controller: c,
                hintText: 'Enter checklist item',
                isRequired: true,
                // Delete icon without circular ripple/hover
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => removeChecklistItem(index),
                    child: const Padding(
                      padding: EdgeInsets.all(8), // comfy tap target, no circle
                      child: Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Admin Notification Checklist 
class NotificationChecklist extends StatelessWidget {
  final String label;
  final List<String> items;
  final List<String> values;            // currently selected
  final ValueChanged<List<String>> onChanged;
  final bool isRequired;

  const NotificationChecklist({
    super.key,
    required this.label,
    required this.items,
    required this.values,
    required this.onChanged,
    this.isRequired = false,
  });

  void _toggle(String item) {
    final next = List<String>.from(values);
    if (next.contains(item)) {
      next.remove(item);
    } else {
      next.add(item);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = values.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),

        // Selected pills (removable)
        if (hasSelection) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((v) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _brand.withOpacity(.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      v,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _brand,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final next = List<String>.from(values)..remove(v);
                        onChanged(next);
                      },
                      child: const Icon(Icons.close, size: 16, color: _brand),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // Checklist container (styled like an InputField, but for a group)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _stroke),
            color: Colors.white,
          ),
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            children: items.map((item) {
              final selected = values.contains(item);
              return InkWell(
                onTap: () => _toggle(item),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      // Checkbox with custom look
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: selected,
                          onChanged: (_) => _toggle(item),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: const BorderSide(color: _stroke, width: 1.2),
                          fillColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) return _brand;
                            return Colors.white;
                          }),
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: _ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Helper / required note (optional)
        if (isRequired)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one option.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _muted,
              ),
            ),
          ),
      ],
    );
  }
}