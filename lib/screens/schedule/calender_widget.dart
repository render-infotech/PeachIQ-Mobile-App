import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/calender_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Models/scheduled_shifts_model.dart';
import 'package:intl/intl.dart';

class ShiftAppointment {
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String shiftTime;

  ShiftAppointment({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.shiftTime,
  });
}

class CalenderWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;
  final ValueChanged<ShiftAppointment>? onAppointmentSelected;

  const CalenderWidget({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.onAppointmentSelected,
  });

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  late List<ShiftAppointment> _shiftAppointments = [];
  final DateTime _currentViewDate = DateTime.now();
  final CalendarController _calendarController = CalendarController();
  late DateTime _selectedMonth;
  bool _isLoading = true;

  static const List<String> _locationOptions = <String>[
    'villa columbo',
    'sample1',
    'sample2',
    'sample3',
  ];
  String _selectedLocation = 'villa columbo';

  List<int> get _yearOptions {
    final int baseYear = _currentViewDate.year;
    return [for (int y = baseYear - 10; y <= baseYear + 10; y++) y];
  }

  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  DateTime? _expandedDate;
  Offset? _expandedTopLeftInStack;
  double? _expandedWidth;
  double? _expandedMaxHeight;

  ShiftAppointment? _selectedAppointment;

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_currentViewDate.year, _currentViewDate.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndSetShifts();
    });
  }

  String _formatTimeFromDateTime(DateTime startTime, DateTime endTime) {
    final String start =
        DateFormat('h a').format(startTime).replaceAll(' ', '');
    final String end = DateFormat('h a').format(endTime).replaceAll(' ', '');
    return '$start to $end';
  }

  Future<void> _fetchAndSetShifts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<CalenderProvider>(context, listen: false);

    await provider.fetchScheduledShifts(forDate: _selectedMonth);

    if (!mounted) return;

    final List<ShiftAppointment> newAppointments =
        provider.schedules.map((shift) {
      final formattedTime = _formatTimeFromDateTime(shift.start, shift.end);
      return ShiftAppointment(
        subject: formattedTime,
        startTime: shift.start,
        endTime: shift.end,
        color: AppColors.primary,
        shiftTime: formattedTime,
      );
    }).toList();

    setState(() {
      _shiftAppointments = newAppointments;
      _isLoading = false;
    });
  }

  List<ShiftAppointment> _getShiftsFor(DateTime date) {
    return _shiftAppointments
        .where((a) => DateUtils.isSameDay(a.startTime, date))
        .toList();
  }

  // REVISED: This method now calculates a larger width and a more flexible height.
  void _openCellOverlay(DateTime date, Rect cellBounds) {
    final calendarBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (calendarBox == null || stackBox == null) return;

    final globalTopLeft = calendarBox.localToGlobal(cellBounds.topLeft);
    final stackTopLeft = stackBox.globalToLocal(globalTopLeft);

    // 1. Increase the width to 1.5x the cell width.
    final double newWidth = cellBounds.width * 1.5;

    // 2. Adjust the left position to keep the wider overlay centered.
    double newLeft = stackTopLeft.dx - (cellBounds.width * 0.25);

    // 3. Ensure the new overlay doesn't go off-screen horizontally.
    final double stackWidth = stackBox.size.width;
    if (newLeft < 0) {
      newLeft = 4; // Add a little padding from the edge
    }
    if (newLeft + newWidth > stackWidth) {
      newLeft = stackWidth - newWidth - 4; // Add padding
    }

    // 4. Calculate available height and remove the restrictive clamp.
    // This allows the overlay to be exactly the height of its content if it fits.
    final availableBelow = stackBox.size.height - stackTopLeft.dy;
    final maxHeight = availableBelow - 8;

    setState(() {
      _expandedDate = date;
      _expandedTopLeftInStack = Offset(newLeft, stackTopLeft.dy);
      _expandedWidth = newWidth;
      _expandedMaxHeight = maxHeight; // No more clamp
    });
  }

  void _closeCellOverlay() {
    setState(() {
      _expandedDate = null;
      _expandedTopLeftInStack = null;
      _expandedWidth = null;
      _expandedMaxHeight = null;
    });
  }

  void _selectAppointment(ShiftAppointment appt) {
    setState(() => _selectedAppointment = appt);
    widget.onAppointmentSelected?.call(appt);
    _closeCellOverlay();
  }

  void _jumpMonth(int delta) {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    setState(() {
      _selectedMonth = next;
      _calendarController.displayDate = _selectedMonth;
      _closeCellOverlay();
    });
    _fetchAndSetShifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      const Text(
                        'Year: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth.year,
                          menuMaxHeight: 12 * kMinInteractiveDimension,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Icon(Icons.arrow_drop_down, size: 18),
                          ),
                          dropdownColor: AppColors.white,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _yearOptions
                              .map((y) => DropdownMenuItem<int>(
                                    value: y,
                                    child: Text('$y'),
                                  ))
                              .toList(),
                          onChanged: (int? year) {
                            if (year == null) return;
                            final int month = _selectedMonth.month;
                            setState(() {
                              _selectedMonth = DateTime(year, month, 1);
                              _calendarController.displayDate = _selectedMonth;
                              _closeCellOverlay();
                            });
                            _fetchAndSetShifts();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Month: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _monthNames[_selectedMonth.month - 1],
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Icon(Icons.arrow_drop_down, size: 18),
                          ),
                          dropdownColor: AppColors.white,
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _monthNames
                              .map((m) => DropdownMenuItem<String>(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            if (value == null) return;
                            final int monthIndex =
                                _monthNames.indexOf(value) + 1;
                            final int year = _selectedMonth.year;
                            setState(() {
                              _selectedMonth = DateTime(year, monthIndex, 1);
                              _calendarController.displayDate = _selectedMonth;
                              _closeCellOverlay();
                            });
                            _fetchAndSetShifts();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        height: 34,
                        width: 160,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    size: 100, color: Colors.white),
                                tooltip: 'Previous month',
                                onPressed: () => _jumpMonth(-1),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 40),
                              IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    size: 100, color: Colors.white),
                                tooltip: 'Next month',
                                onPressed: () => _jumpMonth(1),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 100),
                  const Text(
                    'Location: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      menuMaxHeight: 12 * kMinInteractiveDimension,
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Icon(Icons.arrow_drop_down, size: 18),
                      ),
                      dropdownColor: AppColors.white,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _locationOptions
                          .map((loc) => DropdownMenuItem<String>(
                                value: loc,
                                child: Text(loc),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        if (value == null) return;
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 14,
              ),
            ],
          ),
          Expanded(
            child: Stack(
              key: _stackKey,
              children: [
                GestureDetector(
                  onHorizontalDragStart: (details) {},
                  onHorizontalDragUpdate: (details) {},
                  onHorizontalDragEnd: (details) {},
                  child: Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SfCalendar(
                            key: _calendarKey,
                            controller: _calendarController,
                            view: CalendarView.month,
                            headerHeight: 0,
                            viewHeaderHeight: 20,
                            initialDisplayDate: _currentViewDate,
                            allowViewNavigation: false,
                            firstDayOfWeek: 7,
                            backgroundColor: Colors.white,
                            cellBorderColor: Colors.grey.shade400,
                            todayHighlightColor: AppColors.black,
                            selectionDecoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: AppColors.AppSelectedGreen,
                                width: 1.6,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              shape: BoxShape.rectangle,
                            ),
                            viewHeaderStyle: ViewHeaderStyle(
                              backgroundColor: Colors.grey.shade50,
                              dayTextStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            monthViewSettings: const MonthViewSettings(
                              numberOfWeeksInView: 5,
                              showAgenda: false,
                              appointmentDisplayMode:
                                  MonthAppointmentDisplayMode.none,
                              dayFormat: 'EEE',
                              showTrailingAndLeadingDates: false,
                            ),
                            onTap: (CalendarTapDetails details) {
                              if (details.date != null &&
                                  widget.onDateSelected != null) {
                                if (details.date!.month ==
                                        _selectedMonth.month &&
                                    details.date!.year == _selectedMonth.year) {
                                  widget.onDateSelected!(details.date!);
                                }
                              }
                            },
                            monthCellBuilder: (context, details) {
                              final date = details.date;
                              final isCurrentMonth =
                                  date.month == _selectedMonth.month &&
                                      date.year == _selectedMonth.year;
                              if (!isCurrentMonth)
                                return const SizedBox.shrink();

                              final isToday =
                                  DateUtils.isSameDay(date, DateTime.now());
                              final isSelected = widget.selectedDate != null &&
                                  DateUtils.isSameDay(
                                      date, widget.selectedDate!);

                              final List<ShiftAppointment> shifts = details
                                  .appointments
                                  .cast<ShiftAppointment>()
                                  .toList();
                              final int total = shifts.length;

                              ShiftAppointment? shiftToShow;
                              if (shifts.isNotEmpty) {
                                shiftToShow = shifts.first;
                              }

                              if (_selectedAppointment != null &&
                                  DateUtils.isSameDay(
                                      _selectedAppointment!.startTime,
                                      details.date)) {
                                shiftToShow = _selectedAppointment;
                              }

                              final List<ShiftAppointment> visible =
                                  shiftToShow != null ? [shiftToShow] : [];

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _calendarController.selectedDate = date;
                                  widget.onDateSelected?.call(date);
                                  if (shifts.isNotEmpty) {
                                    widget.onAppointmentSelected
                                        ?.call(shifts.first);
                                  }
                                  _closeCellOverlay();
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 0.3,
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(1, 2, 1, 1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isToday
                                              ? AppColors.primary
                                              : isSelected
                                                  ? AppColors.AppSelectedGreen
                                                  : Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      ...visible.map(
                                        (s) => Container(
                                          height: 14,
                                          width: double.infinity,
                                          margin:
                                              const EdgeInsets.only(bottom: 1),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: s.color,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            s.shiftTime,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (total > 1)
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _openCellOverlay(
                                              date, details.bounds),
                                          child: Text(
                                            '+${total - 1} more',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            dataSource: ShiftDataSource(_shiftAppointments),
                          ),
                  ),
                ),
                if (_expandedDate != null)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _closeCellOverlay,
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (_expandedDate != null &&
                    _expandedTopLeftInStack != null &&
                    _expandedWidth != null &&
                    _expandedMaxHeight != null)
                  Positioned(
                    left: _expandedTopLeftInStack!.dx,
                    top: _expandedTopLeftInStack!.dy,
                    width: _expandedWidth,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(2),
                      child: Builder(
                        builder: (context) {
                          final int _count =
                              _getShiftsFor(_expandedDate!).length;
                          // REVISED: The total height now includes header/padding.
                          final double headerHeight = 24;
                          final double itemHeight =
                              26; // 24 for item + 2 for separator
                          final double totalContentHeight =
                              headerHeight + (_count * itemHeight);

                          final double panelHeight =
                              totalContentHeight < _expandedMaxHeight!
                                  ? totalContentHeight
                                  : _expandedMaxHeight!;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: panelHeight,
                              maxHeight: panelHeight,
                              minWidth: _expandedWidth!,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: _DayOverlayList(
                                date: _expandedDate!,
                                shifts: _getShiftsFor(_expandedDate!),
                                selected: _selectedAppointment,
                                onSelect: _selectAppointment,
                                onClose: _closeCellOverlay,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayOverlayList extends StatelessWidget {
  final DateTime date;
  final List<ShiftAppointment> shifts;
  final ShiftAppointment? selected;
  final ValueChanged<ShiftAppointment> onSelect;
  final VoidCallback onClose;

  const _DayOverlayList({
    required this.date,
    required this.shifts,
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> _weekdaysAbbr = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    final String _formatted = '${date.day} ${_weekdaysAbbr[date.weekday - 1]} ';

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Text(
                _formatted,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView.separated(
            // Prevent scrolling if it's not needed
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero, // Remove any default padding
            shrinkWrap: true,
            itemCount: shifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final s = shifts[index];
              final bool isSelected = identical(s, selected);
              return InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () => onSelect(s),
                child: Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? s.color.withOpacity(0.6)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isSelected ? s.color : Colors.transparent,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.shiftTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize:
                                  10, // Slightly larger font for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShiftDataSource extends CalendarDataSource {
  ShiftDataSource(List<ShiftAppointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;

  @override
  bool isAllDay(int index) => true;
}
