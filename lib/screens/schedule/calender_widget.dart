import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:peach_iq/loading/shimmer_gate.dart';

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

  // New: notify when an appointment is selected from the overlay
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
  late List<ShiftAppointment> _shiftAppointments;
  final DateTime _currentViewDate = DateTime(2025, 9, 1);
  final CalendarController _calendarController = CalendarController();
  DateTime _selectedMonth = DateTime(2025, 9, 1);

  // Location dropdown state (added)
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

  // Keys to compute overlay positioning relative to the calendar/stack
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  // Overlay state
  DateTime? _expandedDate;
  Offset? _expandedTopLeftInStack;
  double? _expandedWidth;
  double? _expandedMaxHeight;

  // Selected appointment state
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
    _generateShiftData();
  }

  void _generateShiftData() {
    _shiftAppointments = [
      // 1 Sep — single shift
      ShiftAppointment(
        subject: 'Front Desk',
        startTime: DateTime(2025, 9, 1, 9, 0),
        endTime: DateTime(2025, 9, 1, 17, 0),
        color: AppColors.primary,
        shiftTime: '9 AM to 5 PM',
      ),

      // 3 Sep — three shifts (shows +N more)
      ShiftAppointment(
        subject: 'Receiving',
        startTime: DateTime(2025, 9, 3, 6, 0),
        endTime: DateTime(2025, 9, 3, 10, 0),
        color: AppColors.primary,
        shiftTime: '6 AM to 10 AM',
      ),
      ShiftAppointment(
        subject: 'Inventory',
        startTime: DateTime(2025, 9, 3, 11, 0),
        endTime: DateTime(2025, 9, 3, 15, 0),
        color: AppColors.primary,
        shiftTime: '11 AM to 3 PM',
      ),
      ShiftAppointment(
        subject: 'Dispatch',
        startTime: DateTime(2025, 9, 3, 16, 0),
        endTime: DateTime(2025, 9, 3, 20, 0),
        color: AppColors.primary,
        shiftTime: '4 PM to 8 PM',
      ),

      // 5 Sep — two shifts
      ShiftAppointment(
        subject: 'Ops A',
        startTime: DateTime(2025, 9, 5, 8, 0),
        endTime: DateTime(2025, 9, 5, 12, 0),
        color: AppColors.primary,
        shiftTime: '8 AM to 12 PM',
      ),
      ShiftAppointment(
        subject: 'Ops B',
        startTime: DateTime(2025, 9, 5, 13, 0),
        endTime: DateTime(2025, 9, 5, 18, 0),
        color: AppColors.primary,
        shiftTime: '1 PM to 6 PM',
      ),

      // 7 Sep — single shift
      ShiftAppointment(
        subject: 'Support',
        startTime: DateTime(2025, 9, 7, 10, 0),
        endTime: DateTime(2025, 9, 7, 19, 0),
        color: AppColors.primary,
        shiftTime: '10 AM to 7 PM',
      ),

      // 10 Sep — three shifts
      ShiftAppointment(
        subject: 'Load-in',
        startTime: DateTime(2025, 9, 10, 5, 0),
        endTime: DateTime(2025, 9, 10, 9, 0),
        color: AppColors.primary,
        shiftTime: '5 AM to 9 AM',
      ),
      ShiftAppointment(
        subject: 'QA',
        startTime: DateTime(2025, 9, 10, 10, 0),
        endTime: DateTime(2025, 9, 10, 14, 0),
        color: AppColors.primary,
        shiftTime: '10 AM to 2 PM',
      ),
      ShiftAppointment(
        subject: 'Pack',
        startTime: DateTime(2025, 9, 10, 15, 0),
        endTime: DateTime(2025, 9, 10, 19, 0),
        color: AppColors.primary,
        shiftTime: '3 PM to 7 PM',
      ),

      // 12 Sep — single shift
      ShiftAppointment(
        subject: 'Client Visit',
        startTime: DateTime(2025, 9, 12, 12, 0),
        endTime: DateTime(2025, 9, 12, 20, 0),
        color: AppColors.primary,
        shiftTime: '12 PM to 8 PM',
      ),

      // 15 Sep — two shifts
      ShiftAppointment(
        subject: 'Morning',
        startTime: DateTime(2025, 9, 15, 7, 0),
        endTime: DateTime(2025, 9, 15, 11, 0),
        color: AppColors.primary,
        shiftTime: '7 AM to 11 AM',
      ),
      ShiftAppointment(
        subject: 'Afternoon',
        startTime: DateTime(2025, 9, 15, 12, 0),
        endTime: DateTime(2025, 9, 15, 16, 0),
        color: AppColors.primary,
        shiftTime: '12 PM to 4 PM',
      ),

      // 18 Sep — three shifts
      ShiftAppointment(
        subject: 'Shift 1',
        startTime: DateTime(2025, 9, 18, 6, 0),
        endTime: DateTime(2025, 9, 18, 10, 0),
        color: AppColors.primary,
        shiftTime: '6 AM to 10 AM',
      ),
      ShiftAppointment(
        subject: 'Shift 2',
        startTime: DateTime(2025, 9, 18, 10, 0),
        endTime: DateTime(2025, 9, 18, 14, 0),
        color: AppColors.primary,
        shiftTime: '10 AM to 2 PM',
      ),
      ShiftAppointment(
        subject: 'Shift 3',
        startTime: DateTime(2025, 9, 18, 14, 0),
        endTime: DateTime(2025, 9, 18, 18, 0),
        color: AppColors.primary,
        shiftTime: '2 PM to 6 PM',
      ),

      // 20 Sep — four shifts (overlay height stress test)
      ShiftAppointment(
        subject: 'Prep',
        startTime: DateTime(2025, 9, 20, 4, 0),
        endTime: DateTime(2025, 9, 20, 8, 0),
        color: AppColors.primary,
        shiftTime: '4 AM to 8 AM',
      ),
      ShiftAppointment(
        subject: 'Stage',
        startTime: DateTime(2025, 9, 20, 8, 0),
        endTime: DateTime(2025, 9, 20, 12, 0),
        color: AppColors.primary,
        shiftTime: '8 AM to 12 PM',
      ),
      ShiftAppointment(
        subject: 'Operate',
        startTime: DateTime(2025, 9, 20, 12, 0),
        endTime: DateTime(2025, 9, 20, 16, 0),
        color: AppColors.primary,
        shiftTime: '12 PM to 4 PM',
      ),
      ShiftAppointment(
        subject: 'Close',
        startTime: DateTime(2025, 9, 20, 16, 0),
        endTime: DateTime(2025, 9, 20, 20, 0),
        color: AppColors.primary,
        shiftTime: '4 PM to 8 PM',
      ),

      // 25 Sep — single shift
      ShiftAppointment(
        subject: 'Maintenance',
        startTime: DateTime(2025, 9, 25, 9, 0),
        endTime: DateTime(2025, 9, 25, 17, 0),
        color: AppColors.primary,
        shiftTime: '9 AM to 5 PM',
      ),

      // 28 Sep — two shifts
      ShiftAppointment(
        subject: 'AM Cover',
        startTime: DateTime(2025, 9, 28, 8, 0),
        endTime: DateTime(2025, 9, 28, 12, 0),
        color: AppColors.primary,
        shiftTime: '8 AM to 12 PM',
      ),
      ShiftAppointment(
        subject: 'PM Cover',
        startTime: DateTime(2025, 9, 28, 13, 0),
        endTime: DateTime(2025, 9, 28, 18, 0),
        color: AppColors.primary,
        shiftTime: '1 PM to 6 PM',
      ),

      // 30 Sep — single shift
      ShiftAppointment(
        subject: 'Reporting',
        startTime: DateTime(2025, 9, 30, 10, 0),
        endTime: DateTime(2025, 9, 30, 18, 0),
        color: AppColors.primary,
        shiftTime: '10 AM to 6 PM',
      ),
    ];
  }

  // Utility: get all shifts for a specific day
  List<ShiftAppointment> _getShiftsFor(DateTime date) {
    return _shiftAppointments
        .where((a) => DateUtils.isSameDay(a.startTime, date))
        .toList();
  }

  // Open/close overlay for the tapped cell (2+ appointments)
  void _openCellOverlay(DateTime date, Rect cellBounds) {
    final calendarBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (calendarBox == null || stackBox == null) return;

    final globalTopLeft = calendarBox.localToGlobal(cellBounds.topLeft);
    final stackTopLeft = stackBox.globalToLocal(globalTopLeft);

    final availableBelow = stackBox.size.height - stackTopLeft.dy;
    final maxHeight = availableBelow - 8;

    setState(() {
      _expandedDate = date;
      _expandedTopLeftInStack = stackTopLeft;
      _expandedWidth = cellBounds.width;
      _expandedMaxHeight = maxHeight.clamp(140.0, 320.0);
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

  // Selection function for an appointment
  void _selectAppointment(ShiftAppointment appt) {
    setState(() => _selectedAppointment = appt);
    widget.onAppointmentSelected?.call(appt);
    _closeCellOverlay();
  }

  // ADDED: navigation helpers
  void _jumpMonth(int delta) {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    setState(() {
      _selectedMonth = next;
      _calendarController.displayDate = _selectedMonth; // navigate month
      _closeCellOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with navigation arrows at the start
          Column(
            children: [
              Row(
                children: [
                  // Year dropdown
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
                              .map(
                                (y) => DropdownMenuItem<int>(
                                  value: y,
                                  child: Text('$y'),
                                ),
                              )
                              .toList(),
                          onChanged: (int? year) {
                            if (year == null) return;
                            final int month = _selectedMonth.month;
                            setState(() {
                              _selectedMonth = DateTime(year, month, 1);
                              _calendarController.displayDate = _selectedMonth;
                              _closeCellOverlay();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Month dropdown
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
                              .map(
                                (m) => DropdownMenuItem<String>(
                                  value: m,
                                  child: Text(m),
                                ),
                              )
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
              // Second row with location dropdown
              Row(
                children: [
                  // FIXED: make the nav container flexible and width-constrained
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
                          .map(
                            (loc) => DropdownMenuItem<String>(
                              value: loc,
                              child: Text(loc),
                            ),
                          )
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

          // Calendar + overlay in a Stack
          Expanded(
            child: Stack(
              key: _stackKey,
              children: [
                // **** THIS IS THE WRAPPER I ADDED to disable horizontal swipes ****
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
                    child: SfCalendar(
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
                          if (details.date!.month == _selectedMonth.month &&
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

                        if (!isCurrentMonth) return const SizedBox.shrink();

                        final isToday =
                            DateUtils.isSameDay(date, DateTime.now());
                        final isSelected = widget.selectedDate != null &&
                            DateUtils.isSameDay(date, widget.selectedDate!);

                        final List<ShiftAppointment> shifts = details
                            .appointments
                            .cast<ShiftAppointment>()
                            .toList();
                        final int total = shifts.length;
                        final List<ShiftAppointment> visible =
                            total > 1 ? shifts.take(1).toList() : shifts;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _calendarController.selectedDate = date; // select
                            widget.onDateSelected?.call(date); // notify
                            if (shifts.isNotEmpty) {
                              widget.onAppointmentSelected?.call(
                                shifts.first,
                              ); // show cards
                            }
                            _closeCellOverlay(); // keep overlay closed on cell tap
                            setState(() {}); // reflect selection immediately
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.3,
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(1, 2, 1, 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date number
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
                                // Render only one visible appointment pill
                                ...visible.map(
                                  (s) => Container(
                                    height: 14,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: s.color,
                                      borderRadius: BorderRadius.circular(3),
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
                                // "+N more" when N = total - 1
                                if (total > 1)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _openCellOverlay(date, details.bounds),
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
                          final int _count = _getShiftsFor(
                            _expandedDate!,
                          ).length;
                          final double _contentHeight = 27.0 * _count;
                          final double _panelHeight =
                              _contentHeight < _expandedMaxHeight!
                                  ? _contentHeight
                                  : _expandedMaxHeight!;
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: _panelHeight,
                              maxHeight: _panelHeight,
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
    // Date header: "{day} {EEE} of {Month}"
    const List<String> _weekdaysAbbr = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final String _formatted = '${date.day} ${_weekdaysAbbr[date.weekday - 1]} ';

    return Column(
      children: [
        const Divider(height: 1),
        // Added header line with date format
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
                        ? s.color.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isSelected ? s.color : Colors.red.shade300,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.shiftTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
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
