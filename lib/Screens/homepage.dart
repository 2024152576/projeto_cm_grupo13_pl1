import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_screen.dart';
import 'review_detail_screen.dart';
import 'add_music_screen.dart';
import 'settings_screen.dart';
import 'package:projeto_cm_grupo13_pl1/models/music.dart';
import 'package:projeto_cm_grupo13_pl1/models/user_model.dart';
import 'package:projeto_cm_grupo13_pl1/models/review_model.dart';
import 'package:projeto_cm_grupo13_pl1/services/auth_service.dart';
import 'package:projeto_cm_grupo13_pl1/services/database_service.dart';
import 'package:projeto_cm_grupo13_pl1/services/lastFM_service.dart';
import 'package:projeto_cm_grupo13_pl1/services/notification_service.dart';
import 'package:projeto_cm_grupo13_pl1/Screens/music_page.dart';
import 'package:projeto_cm_grupo13_pl1/Screens/artist_page.dart';
import 'package:projeto_cm_grupo13_pl1/Screens/user_profile_screen.dart';
import 'package:projeto_cm_grupo13_pl1/models/playlist_model.dart';

enum _SearchMode { music, users, artists }

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  int _bottomNavIndex = 0;

  final LastFmService _lastFmService = LastFmService();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  

  final TextEditingController _searchController =
  TextEditingController();

  List<Music> _results = [];
  List<UserModel> _userResults = [];
  List<Map<String, String>> _artistResults = [];
  _SearchMode _searchMode = _SearchMode.music;
  bool _isLoading = false;
  UserModel? _currentUser;
  StreamSubscription<UserModel?>? _userSub;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance
          .startListening(_authService.currentUser?.uid);
    });
  }

  void _loadCurrentUser() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _userSub = _databaseService.streamUtilizador(uid).listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _formatarTempoRelativo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    return DateFormat('d MMM').format(dateTime);
  }

  String _formatarDataReview(DateTime dateTime) {
    const meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${dateTime.day} de ${meses[dateTime.month - 1]}';
  }

  String _formatarMesAno(DateTime dateTime) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return '${meses[dateTime.month - 1]} ${dateTime.year}';
  }

  ImageProvider _imageFromPath(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.isNotEmpty) return AssetImage(path);
    return const AssetImage('assets/Covers/cdp.jpg');
  }

  Widget _buildAlbumCover(String imagePath, {double size = 70}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: _imageFromPath(imagePath), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildUserAvatar(String userName, {double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFFF8282),
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3746),

        appBar: _bottomNavIndex == 0
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          title: const Text('Decibel', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 26, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF8282),
            indicatorWeight: 3,
            labelColor: Color(0xFFFF8282),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'Música'), Tab(text: 'Listas'), Tab(text: 'Diário')],
          ),
        )
            : _bottomNavIndex == 3
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          centerTitle: true,
          title: const Text('Notificações', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 24, fontWeight: FontWeight.bold)),
          actions: const [Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.filter_alt_outlined, color: Color(0xFFF3E3B6), size: 30))],
        )
            : _bottomNavIndex == 4
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            _currentUser?.fullName ?? 'Perfil',
            style: const TextStyle(color: Color(0xFFF3E3B6), fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Color(0xFFF3E3B6), size: 30),
              color: const Color(0xFF263D4A),
              offset: const Offset(0, 48),
              onSelected: (value) {
                if (value == 'definicoes') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'definicoes',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: Color(0xFFF3E3B6), size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Definições',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
        )
            : null,

        body: IndexedStack(
          index: _bottomNavIndex,
          children: [
            _buildHomeTabs(),
            _buildPesquisaFeed(),
            const SizedBox.shrink(),
            _buildNotificacoesFeed(),
            _buildPerfilFeed(),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeTabs() {
    return TabBarView(children: [_buildMusicaFeed(), _buildListasFeed(), _buildDiarioFeed()]);
  }

  Widget _buildMusicaFeed() {
    return StreamBuilder<List<ReviewModel>>(
      stream: _databaseService.streamTodasReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              'Sem reviews por agora.\nPesquisa uma música e escreve a primeira!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) => _buildPostCard(context, reviews[index]),
        );
      },
    );
  }

  Widget _buildListasFeed() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Inicia sessão para veres as tuas listas', style: TextStyle(color: Colors.grey)));
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('As tuas Listas', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white54, thickness: 1),
            
            // Aqui entra o StreamBuilder
            Expanded(
              child: StreamBuilder<List<PlaylistModel>>(
                stream: _databaseService.streamPlaylistsDoUtilizador(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8282)));
                  }

                  final playlists = snapshot.data ?? [];

                  if (playlists.isEmpty) {
                    return const Center(
                      child: Text('Ainda não tens listas.\nCria a tua primeira lista!', 
                        textAlign: TextAlign.center, 
                        style: TextStyle(color: Colors.grey)
                      )
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: playlists.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      
                      // Usar a imagem da primeira música como capa da playlist (se existir)
                      String imagePath = '';
                      if (playlist.songs.isNotEmpty && playlist.songs.first['imageUrl'] != null) {
                        imagePath = playlist.songs.first['imageUrl'];
                      }

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => PlaylistDetailScreen(playlist: playlist))
                        ),
                        child: _buildPlaylistCard(
                          title: playlist.name, 
                          songCount: '${playlist.songs.length} Músicas', 
                          imagePath: imagePath
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20, right: 20,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePlaylistScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8282),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Criar Lista', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDiarioFeed() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return const Center(
        child: Text(
          'Inicia sessão para ver o teu diário',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return StreamBuilder<List<ReviewModel>>(
      stream: _databaseService.streamReviewsDoUtilizador(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              'Ainda não tens reviews no diário',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final grouped = <String, List<ReviewModel>>{};
        for (final review in reviews) {
          final key = _formatarMesAno(review.timestamp);
          grouped.putIfAbsent(key, () => []).add(review);
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final entry in grouped.entries) ...[
              _buildMonthHeader(entry.key),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      if (i > 0) const SizedBox(height: 15),
                      _buildDiaryCard(entry.value[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _searchHintText() {
    switch (_searchMode) {
      case _SearchMode.users:
        return 'Pesquisar utilizadores (@username, nome...)';
      case _SearchMode.artists:
        return 'Pesquisar artistas';
      case _SearchMode.music:
        return 'Pesquisar música';
    }
  }

  String _searchEmptyMessage() {
    switch (_searchMode) {
      case _SearchMode.users:
        return 'Nenhum utilizador encontrado';
      case _SearchMode.artists:
        return 'Nenhum artista encontrado';
      case _SearchMode.music:
        return 'Pesquise uma música';
    }
  }

  bool _hasSearchResults() {
    switch (_searchMode) {
      case _SearchMode.users:
        return _userResults.isNotEmpty;
      case _SearchMode.artists:
        return _artistResults.isNotEmpty;
      case _SearchMode.music:
        return _results.isNotEmpty;
    }
  }

  int _searchResultCount() {
    switch (_searchMode) {
      case _SearchMode.users:
        return _userResults.length;
      case _SearchMode.artists:
        return _artistResults.length;
      case _SearchMode.music:
        return _results.length;
    }
  }

  Widget _buildSearchModeChip({
    required String label,
    required _SearchMode mode,
  }) {
    final selected = _searchMode == mode;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      selected: selected,
      selectedColor: const Color(0xFFFF8282),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey),
      backgroundColor: const Color(0xFF323232),
      onSelected: (_) {
        setState(() => _searchMode = mode);
        if (_searchController.text.isNotEmpty) {
          _search(_searchController.text);
        }
      },
    );
  }

  Widget _buildPesquisaFeed() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) => _search(value),
              decoration: InputDecoration(
                hintText: _searchHintText(),
                hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSearchModeChip(label: 'Músicas', mode: _SearchMode.music),
                const SizedBox(width: 10),
                _buildSearchModeChip(label: 'Artistas', mode: _SearchMode.artists),
                const SizedBox(width: 10),
                _buildSearchModeChip(label: 'Utilizadores', mode: _SearchMode.users),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearchResults()
                      ? Center(
                          child: Text(
                            _searchEmptyMessage(),
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResultCount(),
                          itemBuilder: (context, index) {
                            if (_searchMode == _SearchMode.users) {
                              final user = _userResults[index];
                              return Card(
                                color: const Color(0xFF323232),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: _buildUserAvatar(user.firstName, radius: 25),
                                  title: Text(
                                    user.fullName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    user.username,
                                    style: const TextStyle(color: Color(0xFFFF8282)),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserProfileScreen(
                                          userId: user.userId,
                                          userName: user.fullName,
                                          profileImagePath: '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }

                            if (_searchMode == _SearchMode.artists) {
                              final artist = _artistResults[index];
                              final name = artist['name'] ?? '';
                              final image = artist['image'] ?? '';
                              return Card(
                                color: const Color(0xFF323232),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image.network(
                                            image,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.white, size: 40),
                                          ),
                                        )
                                      : const Icon(Icons.person, color: Colors.white, size: 40),
                                  title: Text(
                                    name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${artist['listeners'] ?? '0'} ouvintes',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArtistPage(artistName: name),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }

                            final music = _results[index];
                            return Card(
                              color: const Color(0xFF323232),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: music.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          music.imageUrl,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Colors.white, size: 40),
                                        ),
                                      )
                                    : const Icon(Icons.music_note, color: Colors.white, size: 40),
                                title: Text(
                                  music.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(music.artist, style: const TextStyle(color: Colors.grey)),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => MusicPage(music: music)));
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacoesFeed() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return const Center(
        child: Text(
          'Inicia sessão para ver notificações',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<List<ReviewModel>>(
      stream: _databaseService.streamReviewsDeOutros(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              'Sem notificações por agora',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildNotificationItem(
              userName: review.userName,
              action: 'adicionou uma Review',
              time: _formatarTempoRelativo(review.timestamp),
            );
          },
        );
      },
    );
  }

  Widget _buildPerfilFeed() {
    final user = _currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFF8282),
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(user.username, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatColumn(user.reviewsCount, 'Reviews'),
              const SizedBox(width: 30),
              _buildStatColumn(user.followersCount, 'Seguidores'),
              const SizedBox(width: 30),
              _buildStatColumn(user.followingCount, 'A seguir'),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, height: 1),
          _buildFavoritesSection('Artistas Favoritos', user.favoriteArtists, true),
          _buildFavoritesSection('Músicas Favoritas', user.favoriteSongs, false),
          const SizedBox(height: 20),
          _buildReviewsExpansion(user.userId),
          _buildFollowingExpansion(user),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Color(0xFFF3E3B6), fontSize: 12)),
      ],
    );
  }

  Widget _buildFavoritesSection(String title, List<Map<String, String>> items, bool isArtist) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          if (items.isEmpty)
            Text('Sem ${title.toLowerCase()}.', style: const TextStyle(color: Colors.grey, fontSize: 13))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.map((item) {
                  final name = item['name'] ?? '';
                  final image = item['image'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      onTap: () {
                        if (isArtist) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistPage(artistName: name)));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MusicPage(
                                music: Music(
                                  id: item['id'] ?? '',
                                  name: name,
                                  artist: item['artist'] ?? '',
                                  album: '',
                                  listeners: '0',
                                  imageUrl: image,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          isArtist
                              ? CircleAvatar(radius: 40, backgroundImage: _imageFromPath(image))
                              : Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(image: _imageFromPath(image), fit: BoxFit.cover),
                                  ),
                                ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsExpansion(String userId) {
    return ExpansionTile(
      title: const Text('As tuas Reviews', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      iconColor: const Color(0xFFFF8282),
      collapsedIconColor: Colors.white,
      children: [
        StreamBuilder<List<ReviewModel>>(
          stream: _databaseService.streamReviewsDoUtilizador(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final reviews = snapshot.data!;
            if (reviews.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text('Ainda não tens reviews.', style: TextStyle(color: Colors.grey)));
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(review.albumImageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white)),
                  ),
                  title: Text(review.songTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(review.artist, style: const TextStyle(color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF8282), size: 16),
                      Text(' ${review.rating}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewDetailScreen(
                        userId: review.userId,
                        userName: review.userName,
                        date: _formatarDataReview(review.timestamp),
                        profileImagePath: '',
                        songTitle: review.songTitle,
                        artist: review.artist,
                        year: review.timestamp.year.toString(),
                        rating: review.rating,
                        likes: '${review.likes} Gostos',
                        albumImagePath: review.albumImageUrl,
                        fullReviewText: review.fullReviewText,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowingExpansion(UserModel user) {
    if (user.following.isEmpty) {
      return const ListTile(title: Text('A seguir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), subtitle: Text('Ainda não segues ninguém.', style: TextStyle(color: Colors.grey)));
    }

    return ExpansionTile(
      title: const Text('Pessoas que segues', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      iconColor: const Color(0xFFFF8282),
      collapsedIconColor: Colors.white,
      children: [
        FutureBuilder<List<UserModel>>(
          future: _databaseService.obterSeguidos(user.following),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final following = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: following.length,
              itemBuilder: (context, index) {
                final f = following[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF8282),
                    child: Text(f.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(f.fullName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(f.username, style: const TextStyle(color: Color(0xFFFF8282))),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userId: f.userId, userName: f.fullName, profileImagePath: ''))),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuOption(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(color: Color(0xFF263D4A), border: Border(top: BorderSide(color: Colors.white10))),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPostCard(BuildContext context, ReviewModel review) {
    final songTitle = review.songTitle.isNotEmpty ? review.songTitle : 'Música';
    final artist = review.artist.isNotEmpty ? review.artist : 'Artista desconhecido';
    final date = _formatarDataReview(review.timestamp);
    final likes = '${review.likes} ${review.likes == 1 ? 'Gosto' : 'Gostos'}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewDetailScreen(
            userId: review.userId,
            userName: review.userName,
            date: date,
            profileImagePath: '',
            songTitle: songTitle,
            artist: artist,
            year: review.timestamp.year.toString(),
            rating: review.rating,
            likes: likes,
            albumImagePath: review.albumImageUrl,
            fullReviewText: review.fullReviewText,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF263D4A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(review.userName),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        color: Color(0xFFF3E3B6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildAlbumCover(review.albumImageUrl),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        artist,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFF8282),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              review.fullReviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard({required String title, required String songCount, required String imagePath}) {
    return Container(
      padding: const EdgeInsets.all(15), 
      decoration: BoxDecoration(color: const Color(0xFF263D4A), borderRadius: BorderRadius.circular(10)), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold, fontSize: 16)), 
              const SizedBox(height: 4),
              Text(songCount, style: const TextStyle(color: Colors.grey, fontSize: 12))
            ]
          ), 
          Container(
            width: 50, height: 50, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), 
              color: const Color(0xFF1E3746), // Cor de fundo caso não haja imagem
              image: imagePath.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(imagePath), fit: BoxFit.cover)
                  : null,
            ),
            child: imagePath.isEmpty ? const Icon(Icons.music_note, color: Colors.white) : null,
          )
        ]
      )
    );
  }

  Widget _buildDiaryCard(ReviewModel review) {
    final songTitle = review.songTitle.isNotEmpty ? review.songTitle : 'Música';
    final artist = review.artist.isNotEmpty ? review.artist : 'Artista desconhecido';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewDetailScreen(
            userId: review.userId,
            userName: review.userName,
            date: _formatarDataReview(review.timestamp),
            profileImagePath: '',
            songTitle: songTitle,
            artist: artist,
            year: review.timestamp.year.toString(),
            rating: review.rating,
            likes: '${review.likes} ${review.likes == 1 ? 'Gosto' : 'Gostos'}',
            albumImagePath: review.albumImageUrl,
            fullReviewText: review.fullReviewText,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF263D4A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildAlbumCover(review.albumImageUrl),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    songTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(artist, style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFF8282),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String userName,
    required String action,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFFF8282),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF1E3746), fontSize: 14),
                children: [
                  TextSpan(
                    text: '$userName ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: action),
                ],
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String txt) => Container(width: double.infinity, color: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

  Widget _buildGenreCard(String genre) {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFF3E3B6), borderRadius: BorderRadius.circular(15)), child: Text(genre, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10), color: const Color(0xFF292929),
      child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildBottomIcon(Icons.home_outlined, 0),
        _buildBottomIcon(Icons.search, 1),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMusicScreen())), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF3E3B6), width: 2)), child: const Icon(Icons.add, color: Color(0xFFF3E3B6), size: 28))),
        _buildBottomIcon(Icons.notifications_none, 3),
        _buildBottomIcon(Icons.person_outline, 4),
      ])),
    );
  }

  Widget _buildBottomIcon(IconData icon, int idx) => IconButton(icon: Icon(icon), color: _bottomNavIndex == idx ? const Color(0xFFFF8282) : Colors.grey, onPressed: () => setState(() => _bottomNavIndex = idx));

  Widget _buildPlaceholderScreen() => const Center(child: Text('Em breve...', style: TextStyle(color: Colors.white)));


  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _userResults = [];
        _artistResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      switch (_searchMode) {
        case _SearchMode.users:
          final users = await _databaseService.pesquisarUtilizadores(query);
          if (mounted) {
            setState(() {
              _userResults = users;
              _results = [];
              _artistResults = [];
            });
          }
        case _SearchMode.artists:
          final artists = await _lastFmService.searchArtists(query);
          if (mounted) {
            setState(() {
              _artistResults = artists;
              _results = [];
              _userResults = [];
            });
          }
        case _SearchMode.music:
          final results = await _lastFmService.searchTracks(query);
          if (mounted) {
            setState(() {
              _results = results;
              _userResults = [];
              _artistResults = [];
            });
          }
      }
    } catch (e) {
      print(e);
    }

    if (mounted) setState(() => _isLoading = false);
  }
}
