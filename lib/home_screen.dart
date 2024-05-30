import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_space/bloc/auth_bloc.dart';
import 'package:teacher_space/student_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      StudentForm(),
      _buildStudentsPage(),
    ];
  }

  Widget _buildStudentsPage() {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Teachers')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Students')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              (snapshot.hasData && snapshot.data!.docs.length == 0)) {
            return Center(
              child: Text("Empty List"),
            );
          }

          final students = snapshot.data!.docs;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(student['name']),
                  leading: Icon(
                      student['gender'] == "Male" ? Icons.male : Icons.female),
                  subtitle: Text(
                    'DOB: ${student['dob']} || ${student['gender'] == "Male" ? 'Male' : 'Female'}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => StudentFormPage(
                                  dob: student['dob'],
                                  gender: student['gender'],
                                  name: student['name'],
                                  studentId: student.id,
                                ))),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Student',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View Students',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
