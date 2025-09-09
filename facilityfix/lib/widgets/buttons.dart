import 'dart:async';
import 'package:flutter/material.dart';

// Status Tab Selector
class TabItem {
  final String label;
  final int count;

  TabItem({required this.label, required this.count});
}

class StatusTabSelector extends StatelessWidget {
  final List<TabItem> tabs;
  final String selectedLabel;
  final ValueChanged<String> onTabSelected;

  const StatusTabSelector({
    super.key,
    required this.tabs,
    required this.selectedLabel,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: tabs.map((tab) {
          final bool isSelected = selectedLabel == tab.label;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab.label),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0056F8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        tab.label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFEFEFE)
                              : const Color(0xFF475467),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF95555)
                            : const Color(0xFFD0D5DD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${tab.count}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFEFEFE),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Search and Filter Bar --------------------------------------
class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;

  // Classification (optional)
  final String? selectedClassification;
  final List<String>? classifications;
  final void Function(String)? onSearchChanged;
  final void Function(String)? onClassificationChanged;

  // Status (required)
  final String selectedStatus;
  final List<String> statuses;
  final void Function(String) onStatusChanged;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,

    // Classification (optional)
    this.selectedClassification,
    this.classifications,
    this.onSearchChanged,
    this.onClassificationChanged,

    // Status (required)
    required this.selectedStatus,
    required this.statuses,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    // Reusable button builder
    Widget _filterButton({
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          color: const Color(0xFFF4F5FF),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE7E7E8)),
            borderRadius: borderRadius,
          ),
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Center(child: Icon(icon, size: 20, color: Colors.black)),
        ),
      );
    }

    final hasClassification =
        classifications != null &&
        classifications!.isNotEmpty &&
        selectedClassification != null &&
        onClassificationChanged != null;

    return Row(
      children: [
        // Search Field
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: Color(0xFFE5E7E8),
                ),
                borderRadius: borderRadius,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF6E6E70)),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (_, __, ___) {
                      return TextField(
                        controller: searchController,
                        onChanged: (v) => onSearchChanged?.call(v),
                        onSubmitted: (v) => onSearchChanged?.call(v),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.83,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Search work orders...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Color(0xFF6E6E70),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.83,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Clear button
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (_, value, __) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: Color(0xFF6E6E70)),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Clear',
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged?.call('');
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Classification Filter (optional)
        if (hasClassification) ...[
          _filterButton(
            icon: Icons.tune,
            onTap: () async {
              final picked = await _showOptionPickerSheet(
                context,
                title: 'Filter by classification',
                options: classifications!,
                current: selectedClassification!,
              );
              if (picked != null) onClassificationChanged!(picked);
            },
          ),
          const SizedBox(width: 8),
        ],

        // Status Filter 
        _filterButton(
          icon: Icons.filter_list,
          onTap: () async {
            final picked = await _showOptionPickerSheet(
              context,
              title: 'Filter by status',
              options: statuses,
              current: selectedStatus,
            );
            if (picked != null) onStatusChanged(picked);
          },
        ),
      ],
    );
  }
}

/// Bottom sheet picker: list of rows with icons.
Future<String?> _showOptionPickerSheet(
  BuildContext context, {
  required List<String> options,
  required String current,
  String title = 'Select an option',
}) {
  final scheme = Theme.of(context).colorScheme;
  final onSurface = scheme.onSurface;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 12,
            bottom: 8 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // grab handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDEE0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Options list
              Flexible(
                child: Theme(
                  data: Theme.of(ctx).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8), 
                    itemBuilder: (_, i) {
                      final opt = options[i];
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          _iconForOption(opt),
                          size: 18, 
                          color: const Color(0xFF6E6E70),
                        ),
                        title: Text(
                          _labelForOption(opt),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18, 
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                        ),
                        onTap: () => Navigator.pop(ctx, opt), // auto-close
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Friendly label (Title Case) for display.
String _labelForOption(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return s;
  return s
      .split(' ')
      .map((w) =>
          w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

/// Icon mapping for statuses, departments, and announcement categories.
IconData _iconForOption(String raw) {
  final v = raw.trim().toLowerCase();

  // Statuses
  if (v == 'all') return Icons.filter_alt;
  if (v == 'pending') return Icons.hourglass_bottom;
  if (v == 'in progress') return Icons.timelapse;
  if (v == 'on hold') return Icons.pause_circle_filled;
  if (v == 'assigned') return Icons.assignment_ind;
  if (v == 'assessed') return Icons.verified;
  if (v == 'scheduled') return Icons.event_available;
  if (v == 'done' || v == 'completed') return Icons.check_circle;

  // Departments
  if (v == 'hvac') return Icons.ac_unit;
  if (v == 'electrical') return Icons.bolt;
  if (v == 'plumbing') return Icons.plumbing;
  if (v == 'masonry') return Icons.construction;
  if (v == 'carpentry') return Icons.handyman;
  if (v == 'pest control') return Icons.bug_report;

  // Announcement categories
  if (v == 'utility interruption') return Icons.water_drop;
  if (v == 'power outage') return Icons.power_off;
  if (v == 'pest control') return Icons.pest_control;
  if (v == 'maintenance') return Icons.handyman;

  // Default
  return Icons.label_rounded;
}


// Add Button -------------------------------------
class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const AddButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor = const Color(0xFF213ED7),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

// Dropdown
class DropdownField<T> extends StatefulWidget {
  final String label;
  final T? value; // Single value
  final List<T>? values; // Multiple values
  final List<T> items;
  final void Function(T?)? onChanged; // For single select
  final void Function(List<T>)? onChangedMulti; // For multi select
  final bool isRequired;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isMultiSelect;
  final TextEditingController? otherController;

  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.values,
    this.onChanged,
    this.onChangedMulti,
    this.isRequired = false,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isMultiSelect = false,
    this.otherController, String? errorText, required String requiredMessage,
  });

  @override
  State<DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  bool showOtherInput = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isMultiSelect) {
      showOtherInput = widget.value != null && widget.value.toString() == 'Others';
    }
  }

  void _showMultiSelectDialog() async {
    final List<T> selected = List.from(widget.values ?? []);

    final result = await showDialog<List<T>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(widget.label),
            content: SingleChildScrollView(
              child: Column(
                children: widget.items.map((item) {
                  final isSelected = selected.contains(item);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(item.toString()),
                    onChanged: (checked) {
                      setStateDialog(() {
                        if (checked == true) {
                          selected.add(item);
                        } else {
                          selected.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text("OK"),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && widget.onChangedMulti != null) {
      widget.onChangedMulti!(result);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isRequired ? '${widget.label} *' : widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Multi-select mode
          if (widget.isMultiSelect)
            InkWell(
              onTap: _showMultiSelectDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Select ${widget.label}...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: (widget.values ?? [])
                      .map((val) => Chip(label: Text(val.toString())))
                      .toList(),
                ),
              ),
            )
          else
            DropdownButtonFormField<T>(
              value: widget.value,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Select ${widget.label}...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
              ),
              items: widget.items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  showOtherInput = val.toString() == 'Others';
                });
                widget.onChanged?.call(val);
              },
              validator: widget.isRequired
                  ? (val) => val == null ? '${widget.label} is required' : null
                  : null,
            ),

          if (showOtherInput && widget.otherController != null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.otherController,
              decoration: InputDecoration(
                labelText: 'Please specify',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) {
                if (widget.isRequired &&
                    showOtherInput &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please specify';
                }
                return null;
              },
            ),
          ]
        ],
      ),
    );
  }
}

// Work Order Request Type Picker
class RequestTypePicker extends StatefulWidget {
  final String label;
  final bool isRequired;
  final ValueChanged<String> onChanged;

  /// Optional initial preset value (must match one of the items) OR initial custom value if others.
  final String? initialValue;

  const RequestTypePicker({
    super.key,
    this.label = 'Request Type',
    this.isRequired = true,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<RequestTypePicker> createState() => _RequestTypePickerState();
}

class _RequestTypePickerState extends State<RequestTypePicker> {
  static const _presets = <String>[
    'Air Conditioning',
    'Electrical',
    'Civil/Carpentry',
    'Plumbing',
    'Others',
  ];

  String? _selected;          // one of _presets
  final TextEditingController _otherCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize selection from initialValue.
    if (widget.initialValue != null && widget.initialValue!.trim().isNotEmpty) {
      final val = widget.initialValue!.trim();
      if (_presets.contains(val)) {
        _selected = val;
      } else {
        _selected = 'Others';
        _otherCtrl.text = val;
      }
    }

    // Notify parent on init if we have an initial resolved value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_resolvedValue());
    });
  }

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  String _resolvedValue() {
    if (_selected == 'Others') {
      return _otherCtrl.text.trim();
    }
    return _selected ?? '';
  }

  InputDecoration _inputDec({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF98A2B3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field title
        Text(
          labelText,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 6),

        // Dropdown
        DropdownButtonFormField<String>(
          value: _selected,
          isExpanded: true,
          decoration: _inputDec(),
          items: _presets
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() => _selected = val);
            // If switching away from Others, clear other text
            if (val != 'Others') {
              _otherCtrl.clear();
            }
            widget.onChanged(_resolvedValue());
          },
          validator: (val) {
            if (widget.isRequired && (val == null || val.isEmpty)) {
              return 'Please select a request type';
            }
            return null;
          },
        ),

        // Animated "Other" text field
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: (_selected == 'Others')
              ? Padding(
                  key: const ValueKey('others-field'),
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextFormField(
                    controller: _otherCtrl,
                    decoration: _inputDec(hint: 'Please specify'),
                    onChanged: (_) => widget.onChanged(_resolvedValue()),
                    validator: (v) {
                      if (_selected == 'Others' && widget.isRequired) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a custom request type';
                        }
                      }
                      return null;
                    },
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-others')),
        ),
      ],
    );
  }
}

/// A reusable outlined pill-shaped button with optional icon.
class OutlinedPillButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;

  final bool isLoading;

  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  final Color? backgroundColor; // fill behind outline (usually white/transparent)
  final Color? foregroundColor; // icon/text color
  final Color? borderColor;
  final double borderWidth;
  final Color? splashColor;

  final String? tooltip;

  const OutlinedPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.height = 48,
    this.borderRadius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.splashColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final enabled = onPressed != null && !isLoading;

    // Sensible defaults pulled from theme
    final Color fg = (foregroundColor ??
        (enabled ? const Color(0xFF374151) : theme.disabledColor));
    final Color bg = backgroundColor ?? Colors.white;
    final Color br = borderColor ??
        (enabled ? const Color(0xFFD0D5DD) : theme.disabledColor.withOpacity(0.5));
    final Color splash = splashColor ?? theme.colorScheme.primary.withOpacity(0.12);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: br, width: borderWidth),
    );

    Widget button = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Material(
        color: Colors.transparent,
        shape: shape, // for proper ink clipping
        child: Ink(
          decoration: ShapeDecoration(color: bg, shape: shape),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: shape,
            splashColor: splash,
            highlightColor: splash.withOpacity(0.6),
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.trim().isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // Add semantics for accessibility (announce disabled/loading states)
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      value: isLoading ? 'Loading' : null,
      child: button,
    );
  }
}

/// Filled Button (pill)
class FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  final Color backgroundColor;
  final Color textColor;

  final double? width;
  final double height;

  final double borderRadius;
  final TextStyle? textStyle;
  final IconData? leadingIcon;

  final bool isLoading;
  final bool isDisabled;
  final Gradient? gradient;
  final double elevation;

  /// whether to show the outer white container with border
  final bool withOuterBorder;
  final IconData? icon;

  const FilledButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.backgroundColor = const Color(0xFF00A35A), // your green
    this.textColor = Colors.white,
    this.width,
    this.height = 48,
    this.borderRadius = 100,
    this.textStyle,
    this.leadingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.gradient,
    this.elevation = 2.0,
    this.withOuterBorder = true,
    this.icon,
  }) : onPressed = (isDisabled || isLoading) ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = (textStyle ??
            theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            )) ??
        TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        );

    final disabled = onPressed == null;
    final baseColor = disabled ? const Color(0xFFEBECEF) : backgroundColor;
    final fgColor = disabled ? const Color(0xFF9CA3AF) : textColor;

    Color overlay(Color c, double o) => c.withOpacity(o);

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    Widget buttonCore = Material(
      elevation: elevation,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: gradient == null ? baseColor : null,
          gradient: disabled ? null : gradient,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          splashColor: overlay(Colors.white, 0.20),
          highlightColor: overlay(Colors.black, 0.05),
          hoverColor: overlay(Colors.white, 0.06),
          focusColor: overlay(Colors.white, 0.12),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : _ButtonContent(
                      key: const ValueKey('content'),
                      label: label,
                      textStyle: effectiveTextStyle.copyWith(color: fgColor),
                      leadingIcon: leadingIcon,
                      iconColor: fgColor,
                    ),
            ),
          ),
        ),
      ),
    );

    if (withOuterBorder) {
      buttonCore = Material(
        color: const Color(0xFFFEFEFE),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(width: 1, color: Color(0xFFD0D5DD)),
        ),
        child: Padding(
          // ⬇️ no extra vertical height from the wrapper
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: buttonCore,
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        // ⬇️ keep minHeight to the button's own height only
        minHeight: height,
        maxWidth: width ?? double.infinity,
      ),
      child: buttonCore,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final TextStyle textStyle;
  final IconData? leadingIcon;
  final Color iconColor;

  const _ButtonContent({
    super.key,
    required this.label,
    required this.textStyle,
    this.leadingIcon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Text(label, textAlign: TextAlign.center, style: textStyle);
    if (leadingIcon == null) return content;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(leadingIcon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Flexible(child: content),
      ],
    );
  }
}
