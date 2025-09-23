// address_edit_popup.dart
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class AddressData {
  String country;
  String stateProvince;
  String city;
  String addressLine;
  String postalCode;
  String location;
  String about;

  AddressData({
    this.country = '',
    this.stateProvince = '',
    this.city = '',
    this.addressLine = '',
    this.postalCode = '',
    this.location = '',
    this.about = '',
  });
}

class AddressEditPopup extends StatefulWidget {
  final AddressData currentAddress;
  final Function(AddressData) onSave;

  const AddressEditPopup({
    Key? key,
    required this.currentAddress,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddressEditPopup> createState() => _AddressEditPopupState();
}

class _AddressEditPopupState extends State<AddressEditPopup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressLineController;
  late TextEditingController _postalCodeController;
  late TextEditingController _locationController;
  late TextEditingController _aboutController;

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  final List<String> _countries = ['c1', 'c2', 'c3', 'c4'];
  final List<String> _states = ['s1', 's2', 's3', 's4'];
  final List<String> _cities = ['cc1', 'cc2', 'cc3', 'cc4'];

  @override
  void initState() {
    super.initState();
    if (_countries.contains(widget.currentAddress.country)) {
      _selectedCountry = widget.currentAddress.country;
    }
    if (_states.contains(widget.currentAddress.stateProvince)) {
      _selectedState = widget.currentAddress.stateProvince;
    }
    if (_cities.contains(widget.currentAddress.city)) {
      _selectedCity = widget.currentAddress.city;
    }

    _addressLineController =
        TextEditingController(text: widget.currentAddress.addressLine);
    _postalCodeController =
        TextEditingController(text: widget.currentAddress.postalCode);
    _locationController =
        TextEditingController(text: widget.currentAddress.location);
    _aboutController = TextEditingController(text: widget.currentAddress.about);
  }

  @override
  void dispose() {
    _addressLineController.dispose();
    _postalCodeController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
            icon: const SizedBox.shrink(),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Tooltip(
                  message: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.black.withOpacity(0.5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isRequired,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.black.withOpacity(0.5),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Country',
                                hintText: 'CANADA',
                                value: _selectedCountry,
                                items: _countries,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedCountry = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'State/Province',
                                hintText: 'ONTARIO',
                                value: _selectedState,
                                items: _states,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedState = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'City',
                                hintText: 'AJAX',
                                value: _selectedCity,
                                items: _cities,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedCity = newValue;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                label: 'Address Line',
                                controller: _addressLineController,
                                isRequired: true,
                                hintText: 'xxxxx',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTextField(
                                label: 'Postal Code',
                                controller: _postalCodeController,
                                isRequired: true,
                                hintText: 'Enter Postal Code',
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Location',
                                controller: _locationController,
                                isRequired: false,
                                hintText: 'Enter Location',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                label: 'About',
                                controller: _aboutController,
                                isRequired: false,
                                hintText: 'Enter About',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final addressData = AddressData(
                            country: _selectedCountry ?? '',
                            stateProvince: _selectedState ?? '',
                            city: _selectedCity ?? '',
                            addressLine: _addressLineController.text.trim(),
                            postalCode: _postalCodeController.text.trim(),
                            location: _locationController.text.trim(),
                            about: _aboutController.text.trim(),
                          );
                          widget.onSave(addressData);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.AppSelectedGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
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
}

void showAddressEditPopup({
  required BuildContext context,
  required AddressData currentAddress,
  required Function(AddressData) onSave,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddressEditPopup(
        currentAddress: currentAddress,
        onSave: onSave,
      );
    },
  );
}
