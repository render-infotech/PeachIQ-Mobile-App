import 'package:flutter/material.dart';
import 'package:peach_iq/Models/get_address_model.dart';
import 'package:peach_iq/Providers/get_address_details_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:provider/provider.dart';

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

typedef AddressSaveCallback = void Function({
  required int countryId,
  required int stateId,
  required int cityId,
  required String addressLine,
  required String postalCode,
  required String location,
  required String about,
});

class AddressEditPopup extends StatefulWidget {
  final AddressData currentAddress;
  final AddressSaveCallback onSave;

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

  Country? _selectedCountry;
  StateDetails? _selectedState;
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    _addressLineController =
        TextEditingController(text: widget.currentAddress.addressLine);
    _postalCodeController =
        TextEditingController(text: widget.currentAddress.postalCode);
    _locationController =
        TextEditingController(text: widget.currentAddress.location);
    _aboutController = TextEditingController(text: widget.currentAddress.about);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AddressProvider>();
      provider.fetchCountries().then((_) {
        if (!mounted ||
            widget.currentAddress.country.isEmpty ||
            provider.countries.isEmpty) return;
        try {
          final initialCountry = provider.countries.firstWhere(
              (c) => c.countryName == widget.currentAddress.country);
          setState(() {
            _selectedCountry = initialCountry;
          });

          provider.fetchStates(initialCountry.id).then((_) {
            if (!mounted ||
                widget.currentAddress.stateProvince.isEmpty ||
                provider.states.isEmpty) return;
            try {
              final initialState = provider.states.firstWhere(
                  (s) => s.stateName == widget.currentAddress.stateProvince);
              setState(() {
                _selectedState = initialState;
              });

              provider
                  .fetchCities(
                      countryId: initialCountry.id, stateId: initialState.id)
                  .then((_) {
                if (!mounted ||
                    widget.currentAddress.city.isEmpty ||
                    provider.cities.isEmpty) return;
                try {
                  final initialCity = provider.cities.firstWhere(
                      (c) => c.cityName == widget.currentAddress.city);
                  setState(() {
                    _selectedCity = initialCity;
                  });
                } catch (e) {
                  print("Initial city not found in the list.");
                }
              });
            } catch (e) {
              print("Initial state not found in the list.");
            }
          });
        } catch (e) {
          print("Initial country not found in the list.");
        }
      });
    });
  }

  @override
  void dispose() {
    _addressLineController.dispose();
    _postalCodeController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Widget _buildCountryDropdown() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCountries && provider.countries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildDropdownField<Country>(
          label: 'Country',
          hintText: 'Select Country',
          value: _selectedCountry,
          items: provider.countries,
          itemToString: (Country c) => c.countryName,
          onChanged: (Country? newCountry) {
            if (newCountry == null) return;
            setState(() {
              _selectedCountry = newCountry;
              _selectedState = null;
              _selectedCity = null;
            });
            context.read<AddressProvider>().clearCities();
            context.read<AddressProvider>().fetchStates(newCountry.id);
          },
        );
      },
    );
  }

  Widget _buildStateDropdown() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (_selectedCountry == null) {
          return _buildDropdownField<StateDetails>(
            label: 'State/Province',
            hintText: 'Select a country first',
            value: null,
            items: [],
            itemToString: (s) => '',
            onChanged: null,
          );
        }
        if (provider.isLoadingStates) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('State/Province'),
              const SizedBox(height: 8),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return _buildDropdownField<StateDetails>(
          label: 'State/Province',
          hintText: 'Select State',
          value: _selectedState,
          items: provider.states,
          itemToString: (StateDetails s) => s.stateName,
          onChanged: (StateDetails? newState) {
            if (newState == null) return;
            setState(() {
              _selectedState = newState;
              _selectedCity = null;
            });
            context.read<AddressProvider>().fetchCities(
                countryId: _selectedCountry!.id, stateId: newState.id);
          },
        );
      },
    );
  }

  Widget _buildCityDropdown() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        if (_selectedState == null) {
          return _buildDropdownField<City>(
            label: 'City',
            hintText: 'Select a state first',
            value: null,
            items: [],
            itemToString: (c) => '',
            onChanged: null,
          );
        }
        if (provider.isLoadingCities) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('City'),
              const SizedBox(height: 8),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return _buildDropdownField<City>(
          label: 'City',
          hintText: 'Select City',
          value: _selectedCity,
          items: provider.cities,
          itemToString: (City c) => c.cityName,
          onChanged: (City? newCity) {
            setState(() {
              _selectedCity = newCity;
            });
          },
        );
      },
    );
  }

  Widget _buildLabel(String label, {bool isRequired = true}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hintText,
    required T? value,
    required List<T> items,
    required String Function(T) itemToString,
    required ValueChanged<T?>? onChanged,
    double hintFontSize = 12,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
            icon: const SizedBox.shrink(),
            value: value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.black,
            ),
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Tooltip(
                  message: itemToString(item),
                  child: Text(
                    itemToString(item),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            dropdownColor: AppColors.white,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.black.withOpacity(0.5),
                fontSize: hintFontSize,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
              ),
              filled: true,
              fillColor:
                  onChanged == null ? Colors.grey.shade200 : AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            ),
            validator: (value) {
              if (value == null) {
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
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.black.withOpacity(0.5),
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.black.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCountryDropdown()),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStateDropdown()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildCityDropdown(),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: 'Address Line',
                        controller: _addressLineController,
                        isRequired: true,
                        hintText: 'Enter Address Line',
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: 'Postal Code',
                        controller: _postalCodeController,
                        isRequired: true,
                        hintText: 'Enter Postal Code',
                        keyboardType: TextInputType.text,
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(
                          countryId: _selectedCountry?.id ?? 0,
                          stateId: _selectedState?.id ?? 0,
                          cityId: _selectedCity?.id ?? 0,
                          addressLine: _addressLineController.text.trim(),
                          postalCode: _postalCodeController.text.trim(),
                          location: _locationController.text.trim(),
                          about: _aboutController.text.trim(),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
}

void showAddressEditPopup({
  required BuildContext context,
  required AddressData currentAddress,
  required AddressSaveCallback onSave,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return ChangeNotifierProvider.value(
        value: context.read<AddressProvider>(),
        child: AddressEditPopup(
          currentAddress: currentAddress,
          onSave: onSave,
        ),
      );
    },
  );
}
