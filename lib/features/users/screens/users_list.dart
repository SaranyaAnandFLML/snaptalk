import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/global/variables.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';


class UsersList extends ConsumerStatefulWidget {
  const UsersList({super.key});

  @override
  ConsumerState createState() => _HomeState();
}

class _HomeState extends ConsumerState<UsersList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Snap Talk',
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(color: Colors.black),
              fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.fromLTRB(w*0.06, w*0.03, w*0.06, w*0.06),
          child: Column(
            children: [
              Expanded(
                child: ref.watch(getUsersProvider)
                    .when(
                  data: (data){
                    return data.isEmpty
                        ? Center(child: Text('No users found'),)
                        : ListView.separated(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final user = data[index];
                        return InkWell(
                          onTap: (){

                          },
                          child: Container(
                            padding: EdgeInsets.all(w*0.03),
                            decoration: BoxDecoration(
                              color: Palette.whiteColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: w * 0.07,
                                  backgroundColor: const Color(0xFFEADDFE),
                                  backgroundImage: CachedNetworkImageProvider(user.image),
                                ),
                                const SizedBox(width: 15),
                                // Name and message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(user.name,
                                                      style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.bold)),
                                                ),

                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(user.email,
                                          style:  TextStyle(fontSize: w*0.03, color: Palette.greyColor)),
                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.all(w*0.01),
                          child: Divider(
                            height: 1,             // Minimum space
                            color: Palette.lightGrey,    // Custom color
                            thickness: 0.7,        // Thin line
                            indent: 20,            // Optional: left padding
                            endIndent: 20,         // Optional: right padding
                          ),
                        );
                      },

                    );
                  },
                  error: (error, stack){
                    return ErrorText( error: error.toString());
                  },
                  loading: () {
                    return Loader();
                  },

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
