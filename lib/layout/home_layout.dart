import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/components/constants.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if(state is AppInsertDatabaseState){
            onBottomSheetClose(context: context,shouldPopBack: true);
          }
        },
        builder: (context, state) {
          AppCubit appCubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: Text(appCubit.titles[appCubit.currentIndex])),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (appCubit.isBottomSheetShown) {
                  if (formKey.currentState?.validate() == true) {
                    appCubit.insertToDB(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState?.showBottomSheet(
                      (context) => buildBottomSheet(context),
                      elevation: 15.0
                  ).closed.then((value) => onBottomSheetClose(context: context));

                  onBottomSheetOpen(context);
                }
              },
              child: Icon(appCubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: appCubit.currentIndex,
              onTap: (index) {
                appCubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
              ],
            ),
            body: buildBody(context),
          );
        },
      ),
    );
  }

  void onBottomSheetClose({
    required BuildContext context,
    bool shouldPopBack = false
  }) {
    AppCubit appCubit = AppCubit.get(context);
    appCubit.changeBottomSheetState(isBottomSheetShown: false, fabIcon: Icons.edit);
    // setState(() {
    titleController.clear();
    timeController.clear();
    dateController.clear();
    if (shouldPopBack) Navigator.pop(context);
  }

  void onBottomSheetOpen(context) {
    AppCubit appCubit = AppCubit.get(context);
    appCubit.changeBottomSheetState(isBottomSheetShown: true, fabIcon: Icons.done);
  }

  Widget buildBottomSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultFormField(
              controller: titleController,
              type: TextInputType.text,
              label: 'Task Title',
              prefix: Icons.title,
              validate: (String? value) {
                if (value?.isEmpty == true) return 'title must not be empty';
                return null;
              },
            ),
            SizedBox(height: 15),
            defaultFormField(
              controller: timeController,
              type: TextInputType.none,
              label: 'Task Time',
              prefix: Icons.watch_later_outlined,
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then((value) {
                  timeController.text =
                      value?.format(context).toString() ?? timeController.text;
                });
              },
              validate: (String? value) {
                if (value?.isEmpty == true) return 'time must not be empty';
                return null;
              },
            ),
            SizedBox(height: 15),
            defaultFormField(
              controller: dateController,
              type: TextInputType.none,
              label: 'Task Date',
              prefix: Icons.calendar_today,
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.parse('2023-05-03'),
                ).then((value) {
                  dateController.text = DateFormat.yMMMd()
                      .format(value ?? DateTime.parse(dateController.text));
                });
              },
              validate: (String? value) {
                if (value?.isEmpty == true) return 'date must not be empty';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    AppCubit appCubit = AppCubit.get(context);

    if (appCubit is !AppGetDatabaseLoadingState) {
      AppCubit appCubit = AppCubit.get(context);
      return appCubit.screens[appCubit.currentIndex];
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
