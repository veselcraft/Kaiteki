import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/instances.dart';
import 'package:kaiteki/ui/auth/discover_instances/discover_instance_screen_result.dart';
import 'package:kaiteki/ui/auth/discover_instances/discover_instances_screen.dart';
import 'package:kaiteki/ui/auth/login/constants.dart';
import 'package:kaiteki/ui/auth/login/login_form.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:kaiteki/utils/lower_case_text_formatter.dart';

class InstancePage extends StatefulWidget {
  final FutureOr<void> Function(String instance) onNext;
  final FutureOr<void> Function(String instance)? onRegister;
  final bool enabled;

  const InstancePage({
    required this.onNext,
    this.onRegister,
    this.enabled = true,
    super.key,
  });

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  final _formKey = GlobalKey<FormState>();
  final _instanceController = TextEditingController();
  List<InstanceData>? _instances;

  @override
  void initState() {
    super.initState();

    fetchInstances().then(
      (list) => setState(() => _instances = list),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.getL10n();
    return Padding(
      padding: contentMargin,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: fieldMargin,
              child: TypeAheadFormField<InstanceData>(
                textFieldConfiguration: TextFieldConfiguration(
                  // TODO(Craftplacer): `flutter_typeahead` is missing `autofillHints`
                  // autofillHints: const [AutofillHints.url],
                  controller: _instanceController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: fieldPadding,
                    hintText: l10n.instanceFieldHint,
                    prefixIcon: const Icon(Icons.public_rounded),
                    prefixIconConstraints: iconConstraint,
                  ),
                  inputFormatters: [LowerCaseTextFormatter()],
                  keyboardType: TextInputType.url,
                  onSubmitted: (_) => _submit(),
                ),
                enabled: widget.enabled,
                hideOnEmpty: true,
                hideOnLoading: true,
                validator: _validateInstance,
                suggestionsCallback: _fetchSuggestions,
                onSuggestionSelected: (suggestion) {
                  _submitWithInstance(suggestion.name);
                },
                itemBuilder: _buildSuggestionItem,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed:
                      widget.enabled ? _onDiscoverInstancesPressed : null,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.discoverInstancesButtonLabel),
                ),
                const SizedBox(height: 24.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "To add an account, type in the address of the website you want to use.",
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.onRegister == null)
                      const SizedBox()
                    else
                      TextButton(
                        // TODO(Craftplacer): This doesn't call widget.onRegister
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.comfortable,
                        ),
                        child: Text(l10n.registerButtonLabel),
                      ),
                    ElevatedButton(
                      onPressed: widget.enabled ? _onNext : null,
                      style: Theme.of(context).filledButtonStyle.copyWith(
                            visualDensity: VisualDensity.comfortable,
                          ),
                      child: Text(l10n.nextButtonLabel),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (_formKey.currentState?.validate() != true) return;
    _submit.call();
  }

  Widget _buildSuggestionItem(BuildContext context, InstanceData itemData) {
    const fallbackIcon = Icon(Icons.public_rounded);
    return ListTile(
      leading: itemData.favicon == null
          ? fallbackIcon
          : Image.network(
              itemData.favicon!,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => fallbackIcon,
            ),
      title: Text(itemData.name),
    );
  }

  FutureOr<Iterable<InstanceData>> _fetchSuggestions(String pattern) {
    final instances = _instances;

    if (pattern.isEmpty || instances == null) {
      return [];
    }

    return instances.where((instance) {
      return instance.name.contains(pattern);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onNext.call(_instanceController.text);
    }
  }

  Future<void> _onDiscoverInstancesPressed() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DiscoverInstancesScreen(),
      ),
    );

    if (result is DiscoverInstanceScreenResult) {
      _submitWithInstance(result.instance);
      //if (!result.register) {}
    }
  }

  void _submitWithInstance(String instance) {
    widget.onNext.call(_instanceController.text = instance);
  }

  String? _validateInstance(String? value) {
    if (value == null || value.isEmpty) return "Please enter an instance";
    if (!value.contains(".")) return "Please enter a valid instance";

    return null;
  }
}
