import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task.dart';
import 'package:todo/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/components/constants.dart';
import 'package:todo/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitState());

  static AppCubit get(context) => BlocProvider.of(context);

  List<Task> newTasks = [];
  List<Task> doneTasks = [];
  List<Task> archiveTasks = [];

  List<Widget> screens = [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchivedTaskScreen(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  int currentIndex = 0;
  Database? database;
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('az_todo.db', version: 1, onCreate: (db, version) {
      db.execute(
        'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT , date TEXT , time TEXT, status TEXT)',
      );
    }, onOpen: (db) {
      emit(AppGetDatabaseLoadingState());
      getDateFromDB(db);

    }).then((value) {
      database = value;
      print('DB created');
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDB({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database?.transaction((txn) async {
      txn.rawInsert(
        'INSERT INTO tasks (title,date,time,status) VALUES ("$title","$date","$time","$new_")',
      ).then((value) {
        print('$value inserted Successfully');
        emit(AppInsertDatabaseState());

        doIfNotNull(database, (db) {
          getDateFromDB(db);
        });

      }).catchError((error) {
        print('error when insert: ${error.toString}');
        return null;
      });
    });
  }

  void getDateFromDB(Database db)  {
    db.rawQuery('SELECT * FROM tasks').then((value) {
      newTasks.clear();
      doneTasks.clear();
      archiveTasks.clear();

      value.map((e){
        return Task.convertMapToTask(e);
      }).forEach((element) {
        if(element.status == new_) newTasks.add(element);
        else if(element.status == done) doneTasks.add(element);
        else if(element.status == archive) archiveTasks.add(element);
      });

      print('new $newTasks\n\n');
      print('done $doneTasks\n\n');
      print('archive $archiveTasks\n\n');

      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) {
    doIfNotNull(database, (db) {
      db.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id],
      ).then((value){
        emit(AppUpdateDatabaseState());
        getDateFromDB(db);
      });
    });
  }

  void deleteData({
    required int id,
  }) {
    doIfNotNull(database, (db) {
      db.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id]
      ).then((value){
        emit(AppDeleteDatabaseState());
        getDateFromDB(db);
      });
    });
  }

  void changeBottomSheetState(
      {required bool isBottomSheetShown, required IconData fabIcon}) {
    this.isBottomSheetShown = isBottomSheetShown;
    this.fabIcon = fabIcon;
    emit(AppChangeBottomSheetState());
  }
}
