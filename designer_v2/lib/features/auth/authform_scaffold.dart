import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'form_controller.dart';

class AuthFormScaffold extends ConsumerStatefulWidget {
  final String childName;
  final Widget children;

  const AuthFormScaffold({required this.children, Key? key, required this.childName}) : super(key: key);

  @override
  _AuthFormScaffoldState createState() => _AuthFormScaffoldState();
}

class _AuthFormScaffoldState extends ConsumerState<AuthFormScaffold> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final authForm = ref.read(authFormControlProvider(widget.childName))!;

    return ReactiveFormConfig(
        validationMessages: authValidationMessages,
        child: ReactiveFormBuilder(
            form: () => authForm,
            key: formKey,
            builder: (context, form, child) {
              return Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(180, 50, 180, 50),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20)
                      ),
                      width: 800,
                      child: widget.children,
                    ),
                  ]
              );
            }
        )
    );
  }
}