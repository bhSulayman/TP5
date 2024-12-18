import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDb Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].title),
                    subtitle: Text(_movies[index].year),
                    leading: Image.network(_movies[index].poster),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(movie: _movies[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMovies(String query) async {
    const apiKey = 'b8e94c2b';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  final String title;
  final String year;
  final String poster;
  final String imdbID;

  Movie({required this.title, required this.year, required this.poster, required this.imdbID});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      poster: json['Poster'],
      imdbID: json['imdbID'],
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _movieDetails;

  @override
  void initState() {
    super.initState();
    _getMovieDetails();
  }

  Future<void> _getMovieDetails() async {
    const apiKey = 'b8e94c2b';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=${widget.movie.imdbID}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _movieDetails = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title ?? 'Details du film'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _movieDetails == null
              ? Center(child: Text('Erreur de chargement'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.network(
                          _movieDetails!['Poster'],
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Titre: ${_movieDetails!['Title']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ),
                      SizedBox(height: 10),
                      Text('Année: ${_movieDetails!['Year']}'),
                      SizedBox(height: 10),
                      Text('Genre: ${_movieDetails!['Genre']}'),
                      SizedBox(height: 20),
                      Text('Synopsis: ${_movieDetails!['Plot']}'),
                    ],
                  ),
                ),
    );
  }
}
