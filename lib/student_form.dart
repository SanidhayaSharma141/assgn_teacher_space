import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFormPage extends StatefulWidget {
  StudentFormPage(
      {super.key, this.dob, this.gender, this.name, this.studentId});
  String? name;
  String? gender;
  String? dob;
  String? studentId;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Details'),
      ),
      body: StudentForm(
        dob: widget.dob,
        gender: widget.gender,
        name: widget.name,
        studentId: widget.studentId,
      ),
    );
  }
}

class StudentForm extends StatefulWidget {
  StudentForm({super.key, this.dob, this.gender, this.name, this.studentId});
  String? name;
  String? gender;
  String? dob;
  String? studentId;

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.dob != null && widget.gender != null && widget.name != null) {
      _nameController.text = widget.name!;
      _dobController.text = widget.dob!;
      _gender = widget.gender!;
    }
  }

  String _gender = 'Male';
  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      _dobController.text = date.toIso8601String().split('T').first;
    }
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty || _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (widget.name != null) {
      // Update existing student
      await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Students')
          .doc(widget.studentId) // Assuming you have the student's document ID
          .update({
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _gender,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Details Modified Successfully")));
    } else {
      // Add new student
      await FirebaseFirestore.instance
          .collection('Teachers')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Students')
          .add({
        'name': _nameController.text,
        'dob': _dobController.text,
        'gender': _gender,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Details Added Successfully")));
    }

    _nameController.clear();
    _dobController.clear();
    setState(() {
      _gender = 'Male';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.gender == null)
            Text(
              'Add Student',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
            readOnly: true,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _gender,
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue ?? _gender;
              });
            },
            items: <String>['Male', 'Female', 'Other']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _submitData();
              if (widget.dob != null) {
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
