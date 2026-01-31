import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importamos 'services' para usar TextInputFormatter(s)
import 'app_colors.dart';

class InputsText extends StatelessWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const InputsText({
    super.key,
    this.controller,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos TextFormField para poder aprovechar la API de validación
    // que ofrece Flutter mediante `Form` y `FormState`.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      // `inputFormatters` permite controlar/filtrar la entrada mientras
      // el usuario escribe (por ejemplo bloquear números en un nombre).
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: (decoration ?? InputDecoration(
        hintText: hintText,
        labelText: labelText,
      )).copyWith(
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: prefixIcon != null 
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 22)
          : null,
        suffixIcon: suffixIcon != null 
          ? IconButton(
              icon: Icon(suffixIcon, color: AppColors.textSecondary, size: 22),
              onPressed: onSuffixIconPressed,
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      ),
      // `validator` se usa desde un `Form` para validar el campo al
      // invocar `formKey.currentState!.validate()`.
      validator: validator,
    );
  }
}