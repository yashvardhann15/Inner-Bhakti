import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/program.dart';

class ProgramDetailsScreen extends StatefulWidget {
  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  Program? program;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProgramDetails();
  }

  Future<void> _fetchProgramDetails() async {
    final programId = ModalRoute.of(context)?.settings.arguments as String?;
    if (programId != null) {
      try {
        final fetchedProgram = await ApiService.getProgram(programId);
        setState(() {
          program = fetchedProgram;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching program details: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(program?.title ?? 'Program Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 255, 145, 0).withOpacity(0.7),
              const Color.fromARGB(255, 255, 0, 0).withOpacity(0.5),
            ],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(program?.imageUrl ?? ''),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        program?.description ?? 'Description not available',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: program?.episodes.length ?? 0,
                      itemBuilder: (context, index) {
                        final episode = program?.episodes[index];
                        return ListTile(
                          title: Text(episode?.title ?? ''),
                          subtitle: Text(episode?.duration ?? ''),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/player',
                              arguments: {
                                'episodes': program?.episodes,
                                'currentIndex': index,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}