/// Form-field validators for the add/edit expense form.
/// Each returns a user-facing error string, or null when valid — the
/// signature `TextFormField` expects for its `validator` parameter.
class Validators {
  Validators._();

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (value.trim().length > 60) {
      return 'Title must be 60 characters or fewer';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    if (parsed > 100000000) {
      return 'Amount is too large';
    }
    return null;
  }

  static String? note(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Note must be 200 characters or fewer';
    }
    return null;
  }
}
