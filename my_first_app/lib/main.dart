import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const StudentStudyPlannerApp());
}

class StudentStudyPlannerApp extends StatelessWidget {
  const StudentStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Study Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff5B5FEF),
          brightness: Brightness.light,
        ),
      ),
      home: const StudyPlannerHome(),
    );
  }
}

class StudyTask {
  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.completed = false,
  });

  final int id;
  final String title;
  final String subject;
  final DateTime dueDate;
  bool completed;
}

enum TaskStatus {
  safe,
  warning,
  urgent,
  completed,
}

class StudyPlannerHome extends StatefulWidget {
  const StudyPlannerHome({super.key});

  @override
  State<StudyPlannerHome> createState() => _StudyPlannerHomeState();
}

class _StudyPlannerHomeState extends State<StudyPlannerHome> {
  int selectedTab = 0;
  String selectedSubject = 'All';
  Timer? timer;

  final Set<String> shownAlerts = {};

  final List<StudyTask> tasks = [
    StudyTask(
      id: 1,
      title: 'Finish algebra worksheet',
      subject: 'Mathematics',
      dueDate: DateTime.now().add(const Duration(hours: 5)),
    ),
    StudyTask(
      id: 2,
      title: 'Read chapter 4',
      subject: 'Biology',
      dueDate: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    ),
    StudyTask(
      id: 3,
      title: 'Write essay outline',
      subject: 'English',
      dueDate: DateTime.now().add(const Duration(minutes: 12)),
    ),
    StudyTask(
      id: 4,
      title: 'Review motion notes',
      subject: 'Physics',
      dueDate: DateTime.now().add(const Duration(days: 1, hours: 3)),
    ),
  ];

  final Map<String, Color> subjectColors = {
    'Mathematics': const Color(0xff685DFF),
    'Biology': const Color(0xff10A37F),
    'English': const Color(0xffF59E0B),
    'Physics': const Color(0xffEC5D78),
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTaskAlerts();
    });

    timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        if (!mounted) return;

        setState(() {});
        checkTaskAlerts();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildSchedulePage(),
      buildSubjectsPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF4F6FF),
      body: buildBackground(
        SafeArea(
          child: pages[selectedTab],
        ),
      ),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: showAddTaskSheet,
              backgroundColor: const Color(0xff5B5FEF),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xffE8E8FF),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildBackground(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffF8F9FF),
            Color(0xffEEF0FF),
            Color(0xffF8F6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -85,
            right: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffC9CCFF).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -90,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffD9F6EC).withValues(alpha: 0.6),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final completed = tasks.where((task) => task.completed).length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 105),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Planner',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff1E2038),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Stay focused. Stay ahead.',
                    style: TextStyle(
                      color: Color(0xff73778C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xff5B5FEF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        buildProgressCard(completed, progress),
        const SizedBox(height: 24),
        buildStatusGuide(),
        const SizedBox(height: 25),
        const Text(
          "Today's tasks",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xff1E2038),
          ),
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          buildEmptyCard()
        else
          ...tasks.map(buildTaskCard),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: buildQuickCard(
                '${tasks.length}',
                'Total tasks',
                Icons.assignment_outlined,
                const Color(0xff5B5FEF),
                () {
                  setState(() {
                    selectedTab = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildQuickCard(
                '$completed',
                'Completed',
                Icons.task_alt_rounded,
                const Color(0xff15A37F),
                showProgressDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildProgressCard(int completed, double progress) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff5B5FEF),
            Color(0xff7C6FF0),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5B5FEF).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S PROGRESS',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$completed of ${tasks.length} tasks completed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusGuide() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatusLegend(
            color: Color(0xff18A878),
            text: 'Plenty of time',
          ),
          StatusLegend(
            color: Color(0xffF0A51A),
            text: 'Do it soon',
          ),
          StatusLegend(
            color: Color(0xffE8505B),
            text: 'Deadline',
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(StudyTask task) {
    final status = getTaskStatus(task);
    final color = getStatusColor(status);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          tasks.remove(task);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  tasks.add(task);
                });
              },
            ),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xffE8505B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            task.completed = !task.completed;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    task.completed = !task.completed;
                  });
                },
                child: Icon(
                  task.completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 5,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.completed
                            ? const Color(0xffA5A8B4)
                            : const Color(0xff24263B),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${task.subject} • ${formatDate(task.dueDate)}',
                      style: const TextStyle(
                        color: Color(0xff75798C),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      getTimeLabel(task),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  showTaskOptions(task);
                },
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xff8F93A3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuickCard(
    String value,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff777B8E),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSchedulePage() {
    final sortedTasks = [...tasks]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xff1E2038),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your study timeline and deadlines.',
          style: TextStyle(color: Color(0xff73778C)),
        ),
        const SizedBox(height: 24),
        if (sortedTasks.isEmpty)
          buildEmptyCard()
        else
          ...sortedTasks.map(buildScheduleCard),
      ],
    );
  }

  Widget buildScheduleCard(StudyTask task) {
    final status = getTaskStatus(task);
    final color = getStatusColor(status);

    return InkWell(
      onTap: () {
        setState(() {
          task.completed = !task.completed;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                formatTime(task.dueDate),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${task.subject} • ${getTimeLabel(task)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              task.completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubjectsPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xff1E2038),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Choose a subject to view its tasks.',
          style: TextStyle(color: Color(0xff73778C)),
        ),
        const SizedBox(height: 24),
        ...subjectColors.entries.map(
          (entry) => buildSubjectCard(
            entry.key,
            entry.value,
          ),
        ),
      ],
    );
  }

  Widget buildSubjectCard(String subject, Color color) {
    final subjectTasks =
        tasks.where((task) => task.subject == subject).toList();

    final completed =
        subjectTasks.where((task) => task.completed).length;

    return InkWell(
      onTap: () {
        setState(() {
          selectedSubject = subject;
          selectedTab = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Showing $subject tasks'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: 0.13),
              child: Icon(
                getSubjectIcon(subject),
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of ${subjectTasks.length} tasks completed',
                    style: const TextStyle(
                      color: Color(0xff777B8E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xffA0A3B1),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfilePage() {
    final completed = tasks.where((task) => task.completed).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xffDCDDFE),
          child: Icon(
            Icons.school_rounded,
            size: 42,
            color: Color(0xff5B5FEF),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Student',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Focused learning, every day.',
            style: TextStyle(color: Color(0xff73778C)),
          ),
        ),
        const SizedBox(height: 28),
        buildProfileCard(
          Icons.task_alt_rounded,
          'Completed tasks',
          '$completed',
          showProgressDialog,
        ),
        buildProfileCard(
          Icons.delete_outline_rounded,
          'Clear completed tasks',
          '',
          clearCompletedTasks,
        ),
        buildProfileCard(
          Icons.info_outline_rounded,
          'Task status guide',
          '',
          showStatusGuide,
        ),
      ],
    );
  }

  Widget buildProfileCard(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xff5B5FEF),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xff777B8E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xffA2A5B3),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 45,
            color: Color(0xff5B5FEF),
          ),
          SizedBox(height: 12),
          Text(
            'Everything is clear!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add a task to plan your next study session.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff777B8E)),
          ),
        ],
      ),
    );
  }

  TaskStatus getTaskStatus(StudyTask task) {
    if (task.completed) {
      return TaskStatus.completed;
    }

    final difference = task.dueDate.difference(DateTime.now());

    if (difference.inMinutes <= 15) {
      return TaskStatus.urgent;
    }

    if (difference.inHours <= 2) {
      return TaskStatus.warning;
    }

    return TaskStatus.safe;
  }

  Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.safe:
        return const Color(0xff18A878);
      case TaskStatus.warning:
        return const Color(0xffF0A51A);
      case TaskStatus.urgent:
        return const Color(0xffE8505B);
      case TaskStatus.completed:
        return const Color(0xff18A878);
    }
  }

  String getTimeLabel(StudyTask task) {
    if (task.completed) {
      return 'Completed';
    }

    final difference = task.dueDate.difference(DateTime.now());

    if (difference.isNegative) {
      return 'Deadline passed';
    }

    if (difference.inMinutes <= 15) {
      return 'Deadline soon • ${difference.inMinutes} min left';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes available';
    }

    if (difference.inHours <= 2) {
      return 'Do this soon • ${difference.inHours}h left';
    }

    if (difference.inDays >= 1) {
      return '${difference.inDays} day(s) available';
    }

    return '${difference.inHours} hours available';
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} • ${formatTime(date)}';
  }

  String formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  IconData getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.calculate_outlined;
      case 'Biology':
        return Icons.biotech_outlined;
      case 'English':
        return Icons.edit_note_outlined;
      case 'Physics':
        return Icons.bolt_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  void checkTaskAlerts() {
    for (final task in tasks) {
      if (task.completed) continue;

      final difference = task.dueDate.difference(DateTime.now());

      String? alertType;
      String? message;

      if (difference.isNegative) {
        alertType = 'deadline';
        message = '${task.title}: the deadline has passed.';
      } else if (difference.inMinutes <= 15) {
        alertType = 'urgent';
        message =
            '${task.title}: only ${difference.inMinutes} minutes left!';
      } else if (difference.inHours <= 2) {
        alertType = 'warning';
        message =
            '${task.title}: less than 2 hours remain. Start soon.';
      }

      if (alertType != null && !shownAlerts.contains('${task.id}-$alertType')) {
        shownAlerts.add('${task.id}-$alertType');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: alertType == 'urgent' || alertType == 'deadline'
                ? const Color(0xffD94550)
                : const Color(0xffD98D00),
            content: Text(message!),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'DONE',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  task.completed = true;
                });
              },
            ),
          ),
        );
      }
    }
  }

  void showAddTaskSheet() {
    final titleController = TextEditingController();
    String subject = 'Mathematics';
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: Color(0xffB1B5C2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Plan a study task',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        hintText: 'Example: Complete biology notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: subject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: subjectColors.keys.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          subject = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: selectedDate,
                        );

                        if (date == null || !context.mounted) return;

                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );

                        if (time == null) return;

                        setSheetState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff747887),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: Color(0xff5B5FEF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Deadline: ${formatDate(selectedDate)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.edit_outlined),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff5B5FEF),
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            return;
                          }

                          setState(() {
                            tasks.add(
                              StudyTask(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch,
                                title: titleController.text.trim(),
                                subject: subject,
                                dueDate: selectedDate,
                              ),
                            );
                          });

                          Navigator.pop(context);
                        },
                        child: const Text('Create task'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showTaskOptions(StudyTask task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  task.completed
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                ),
                title: Text(
                  task.completed
                      ? 'Mark as incomplete'
                      : 'Mark as completed',
                ),
                onTap: () {
                  setState(() {
                    task.completed = !task.completed;
                  });

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xffE8505B),
                ),
                title: const Text(
                  'Delete task',
                  style: TextStyle(color: Color(0xffE8505B)),
                ),
                onTap: () {
                  setState(() {
                    tasks.remove(task);
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showProgressDialog() {
    final completed = tasks.where((task) => task.completed).length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Progress summary'),
          content: Text(
            'You have completed $completed out of ${tasks.length} tasks.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showStatusGuide() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Deadline colors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.circle,
                  color: Color(0xff18A878),
                ),
                title: Text('Green'),
                subtitle: Text('You have more than 2 hours available.'),
              ),
              ListTile(
                leading: Icon(
                  Icons.circle,
                  color: Color(0xffF0A51A),
                ),
                title: Text('Yellow'),
                subtitle: Text('You have less than 2 hours available.'),
              ),
              ListTile(
                leading: Icon(
                  Icons.circle,
                  color: Color(0xffE8505B),
                ),
                title: Text('Red'),
                subtitle: Text('The deadline is within 15 minutes or passed.'),
              ),
            ],
          ),
        );
      },
    );
  }

  void clearCompletedTasks() {
    final completed = tasks.where((task) => task.completed).length;

    if (completed == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no completed tasks to clear.'),
        ),
      );
      return;
    }

    setState(() {
      tasks.removeWhere((task) => task.completed);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed tasks cleared.'),
      ),
    );
  }
}

class StatusLegend extends StatelessWidget {
  const StatusLegend({
    super.key,
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: 15,
        ),
        const SizedBox(height: 5),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xff676B7C),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}