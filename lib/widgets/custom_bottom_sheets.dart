import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class CustomBottomSheets {
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  static Future<bool?> showConfirmationBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) {
    return showCustomBottomSheet<bool>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDangerous 
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isDangerous ? AppColors.error : AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderMedium),
                    ),
                    child: Text(
                      cancelText,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? 
                        (isDangerous ? AppColors.error : AppColors.primaryGold),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showInfoBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Got it',
    IconData? icon,
    Color? iconColor,
  }) {
    return showCustomBottomSheet<void>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.info).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppColors.info,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> showInputBottomSheet({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showCustomBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(cancelText),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.of(context).pop(controller.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> showSelectionBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<SelectionItem<T>> items,
    T? selectedValue,
    String? searchHint,
    bool showSearch = false,
  }) {
    return showCustomBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      height: MediaQuery.of(context).size.height * 0.7,
      child: SelectionBottomSheetContent<T>(
        title: title,
        items: items,
        selectedValue: selectedValue,
        searchHint: searchHint,
        showSearch: showSearch,
      ),
    );
  }

  static Future<void> showLoadingBottomSheet({
    required BuildContext context,
    required String message,
  }) {
    return showCustomBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;

  const SelectionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
  });
}

class SelectionBottomSheetContent<T> extends StatefulWidget {
  final String title;
  final List<SelectionItem<T>> items;
  final T? selectedValue;
  final String? searchHint;
  final bool showSearch;

  const SelectionBottomSheetContent({
    super.key,
    required this.title,
    required this.items,
    this.selectedValue,
    this.searchHint,
    this.showSearch = false,
  });

  @override
  State<SelectionBottomSheetContent<T>> createState() => 
      _SelectionBottomSheetContentState<T>();
}

class _SelectionBottomSheetContentState<T> 
    extends State<SelectionBottomSheetContent<T>> {
  late List<SelectionItem<T>> filteredItems;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = widget.items.where((item) {
        return item.title.toLowerCase().contains(query) ||
               (item.subtitle?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              if (widget.showSearch) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isSelected = item.value == widget.selectedValue;
              
              return ListTile(
                leading: item.leading ?? 
                  (item.icon != null ? Icon(item.icon) : null),
                title: Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                  ),
                ),
                subtitle: item.subtitle != null 
                  ? Text(
                      item.subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
                trailing: isSelected 
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGold,
                    )
                  : null,
                onTap: () => Navigator.of(context).pop(item.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Utility methods for common bottom sheets
class CommonBottomSheets {
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
  }) {
    return CustomBottomSheets.showConfirmationBottomSheet(
      context: context,
      title: 'Delete $itemName?',
      message: 'This action cannot be undone. Are you sure you want to delete this $itemName?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline,
      isDangerous: true,
    );
  }

  static Future<bool?> showLogoutConfirmation({
    required BuildContext context,
  }) {
    return CustomBottomSheets.showConfirmationBottomSheet(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your account?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      icon: Icons.logout,
      isDangerous: true,
    );
  }

  static Future<void> showSuccessMessage({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return CustomBottomSheets.showInfoBottomSheet(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
    );
  }

  static Future<void> showErrorMessage({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return CustomBottomSheets.showInfoBottomSheet(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
  }
}