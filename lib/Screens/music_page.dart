import 'package:flutter/material.dart';
import '../models/music.dart';

class MusicPage extends StatelessWidget {
  final Music music;

  const MusicPage({
    super.key,
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF18384B);
    const yellowColor = Color(0xFFF5D98E);
    const pinkColor = Color(0xFFFF7D7D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          "Decibel",
                          style: TextStyle(
                            color: yellowColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_horiz,
                        color: yellowColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            music.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            music.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Text(
                            "Álbum",
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            music.album.isEmpty
                                ? "Desconhecido"
                                : music.album,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            "Listeners",
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            music.listeners,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(8),
                      child: music.imageUrl.isNotEmpty
                          ? Image.network(
                        music.imageUrl,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 140,
                        height: 140,
                        color: Colors.black26,
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Divider(
                color: Colors.white24,
                thickness: 1,
                height: 1,
              ),

              const TabBar(
                indicatorColor: pinkColor,
                labelColor: Colors.white,
                unselectedLabelColor:
                Colors.white54,
                tabs: [
                  Tab(text: "Comunidade"),
                  Tab(text: "Amigos"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      padding:
                      const EdgeInsets.all(20),
                      children: const [
                        Text(
                          "Reviews da comunidade aparecerão aqui.",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    ListView(
                      padding:
                      const EdgeInsets.all(20),
                      children: const [
                        Text(
                          "Atividade dos amigos aparecerá aqui.",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            30),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Adicionar Review",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}