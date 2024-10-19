import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/program.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<Episode>? _episodes;
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isSliderMoving = false;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        setState(() {
          _episodes = arguments['episodes'] as List<Episode>?;
          _currentIndex = arguments['currentIndex'] ?? 0;
        });
        _loadAudio();
      }
    });
  }

  void _initializeAudioPlayer() async {
    // Configure for web audio playback
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    if (kIsWeb) {
      await _audioPlayer.setSourceAsset(''); // Initialize with empty source
    }
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted && !_isSliderMoving) {
        setState(() {
          _duration = d;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted && !_isSliderMoving) {
        setState(() {
          _position = p;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.stopped || state == PlayerState.completed) {
            _isLoading = false;
          }
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        if (_currentIndex < (_episodes?.length ?? 0) - 1) {
          _playNext();
        }
      }
    });
  }

  Future<void> _loadAudio() async {
    if (_episodes == null || _episodes!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    try {
      final audioUrl = _episodes![_currentIndex].audioUrl;
      _currentAudioUrl = audioUrl;
      print('Loading audio: $audioUrl');

      await _audioPlayer.stop();

      if (kIsWeb) {
        // For web, try different loading strategies
        try {
          final audioPath = 'assets/audio/$audioUrl';
          print('Web audio path: $audioPath');
          
          // First attempt with UrlSource
          await _audioPlayer.setSource(UrlSource(audioPath));
        } catch (e) {
          print('Web UrlSource failed, trying AssetSource: $e');
          // Fallback to AssetSource
          await _audioPlayer.setSource(AssetSource('audio/$audioUrl'));
        }
      } else {
        // For mobile platforms
        final audioPath = 'audio/$audioUrl';
        await _audioPlayer.setSource(AssetSource(audioPath));
      }

      print('Audio source set successfully');

      final duration = await _audioPlayer.getDuration();
      if (duration != null && mounted) {
        setState(() {
          _duration = duration;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading audio: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playPause() async {
    if (_isLoading) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final audioUrl = _episodes![_currentIndex].audioUrl;
        if (_currentAudioUrl != audioUrl) {
          await _loadAudio();
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('Error in play/pause: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (_isLoading) return;

    try {
      final audioUrl = _episodes![_currentIndex].audioUrl;
      if (_currentAudioUrl != audioUrl) {
        await _loadAudio();
      }

      await _audioPlayer.seek(position);
      if (mounted) {
        setState(() {
          _position = position;
        });
      }

      if (!_isPlaying) {
        await _playPause();
      }
    } catch (e) {
      print('Error seeking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seeking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _playNext() async {
    if (_isLoading || _currentIndex >= (_episodes?.length ?? 0) - 1) return;

    setState(() {
      _currentIndex++;
      _isPlaying = false;
    });

    await _loadAudio();
    await _playPause();
  }

  Future<void> _playPrevious() async {
    if (_isLoading || _currentIndex <= 0) return;

    setState(() {
      _currentIndex--;
      _isPlaying = false;
    });

    await _loadAudio();
    await _playPause();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

@override
  Widget build(BuildContext context) {
    final episode = _episodes?[_currentIndex];
    final hasNext = _currentIndex < (_episodes?.length ?? 0) - 1;
    final hasPrevious = _currentIndex > 0;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/program${_currentIndex + 1}/episode${_currentIndex + 1}.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
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
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          episode?.title ?? 'Player',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          // Add menu functionality if needed
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Playing ${episode?.title ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.white,
                            ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 4,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 16),
                              ),
                              child: Slider(
                                value: _position.inSeconds.toDouble(),
                                max: _duration.inSeconds > 0
                                    ? _duration.inSeconds.toDouble()
                                    : 1,
                                min: 0,
                                onChangeStart: (_) {
                                  setState(() {
                                    _isSliderMoving = true;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _position =
                                        Duration(seconds: value.toInt());
                                  });
                                },
                                onChangeEnd: (value) {
                                  setState(() {
                                    _isSliderMoving = false;
                                  });
                                  _seekTo(Duration(seconds: value.toInt()));
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous),
                                  iconSize: 64,
                                  color: hasPrevious
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  onPressed: hasPrevious && !_isLoading
                                      ? _playPrevious
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(_isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled),
                                  iconSize: 84,
                                  color: _isLoading
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white,
                                  onPressed: _isLoading ? null : _playPause,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  iconSize: 64,
                                  color: hasNext
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  onPressed:
                                      hasNext && !_isLoading ? _playNext : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}