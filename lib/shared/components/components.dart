import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/shared/components/constants.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function(String)? onSubmit,
  Function(String)? onChange,
  Function()? onTap,
  bool isPassword = false,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function()? suffixPressed,
  bool isClickable = true,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    enabled: isClickable,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
    onTap: onTap,
    validator: validate,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        prefix,
      ),
      suffixIcon: suffix != null
          ? IconButton(
              onPressed: suffixPressed,
              icon: Icon(
                suffix,
              ),
            )
          : null,
      border: OutlineInputBorder(),
    ),
  );
}

Widget buildTaskItem(Task task, BuildContext context) => Dismissible(
      key: UniqueKey(),
      onDismissed:(direction) {
        AppCubit.get(context).deleteData(id: task.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35.0,
              child: Text(task.time),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(height: 12),
                  Text(
                    task.date,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.0),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(status: done, id: task.id);
              },
              icon: Icon(Icons.check_box, color: Colors.green),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(status: archive, id: task.id);
              },
              icon: Icon(Icons.archive, color: Colors.black45),
            ),
          ],
        ),
      ),
    );

void doIfNotNull<T>(T? t, Function(T) action) {
  if (t != null) action(t);
}

Widget buildBottomScreenBody(BuildContext context, List<Task> tasks) {
  if(tasks.isEmpty){
    return Center(
      child: Text('No task yet, Please add tasks.',
          style: TextStyle(
            color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 20.0
      )),
    );
  }else{
    return ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index],context),
      separatorBuilder: (_, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey,
        ),
      ),
      itemCount: tasks.length,
    );
  }
}
