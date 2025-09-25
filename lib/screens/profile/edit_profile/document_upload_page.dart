import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/Providers/document_provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _membershipController = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _membershipController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isIssueDate) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = selectedDate;
        } else {
          _expiryDate = selectedDate;
        }
      });
    }
  }

  /// This function handles picking a file from the device.
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  /// This function validates the form and calls the provider to upload the document.
  Future<void> _submitForm() async {
    // 1. Validate all text fields
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // 2. Check if a file has been selected
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a document to upload.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    // 3. Check if dates have been selected
    if (_issueDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both issue and expiry dates.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // 4. Validate the date logic
    if (_expiryDate!.isBefore(_issueDate!)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Date'),
          content:
              const Text('The expiry date cannot be before the issue date.'),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // 5. Call the provider to perform the API POST request
    final provider = context.read<DocumentProvider>();
    final success = await provider.uploadDocument(
      documentName: _nameController.text,
      type: _typeController.text,
      membershipName: _membershipController.text,
      file: _selectedFile!,
      issueDate: _issueDate!,
      expiryDate: _expiryDate!,
    );

    // 6. Show feedback to the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Document uploaded successfully!'
              : provider.errorMessage ?? 'Upload failed.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();

    return Material(
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: Column(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, p, _) => HeaderCard(
                  name: p.fullName,
                  subtitle: p.email.isNotEmpty ? p.email : null,
                  pageheader: 'Document Details',
                  onSignOut: () {},
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _nameController,
                                  label: 'Name',
                                  hint: 'Document Name',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _typeController,
                                  label: 'Type',
                                  hint: 'Document Type',
                                  isRequired: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _membershipController,
                            label:
                                'Membership of Any Association or Institution',
                            hint: 'Membership Name',
                            isRequired: false,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Document',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    // This InkWell handles the tap action for picking a file
                                    InkWell(
                                      onTap: _pickFile,
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: _selectedFile == null
                                              ? const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        CupertinoIcons
                                                            .cloud_upload,
                                                        color: Colors.orange,
                                                        size: 40),
                                                    SizedBox(height: 8),
                                                    Text('Tap to Upload'),
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.file_present,
                                                        color:
                                                            AppColors.primary,
                                                        size: 40),
                                                    const SizedBox(height: 8),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Text(
                                                        _selectedFile!.name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildDatePicker(
                                      label: 'Document Issue Date',
                                      selectedDate: _issueDate,
                                      onTap: () => _pickDate(context, true),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildDatePicker(
                                      label: 'Document Expiry Date',
                                      selectedDate: _expiryDate,
                                      onTap: () => _pickDate(context, false),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              // The onPressed calls the _submitForm method
                              onPressed:
                                  docProvider.isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: docProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Add'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Choose Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: TextStyle(
                    color: selectedDate == null
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                const Icon(CupertinoIcons.calendar, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
