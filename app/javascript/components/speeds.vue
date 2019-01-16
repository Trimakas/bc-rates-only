<template>
  <v-app>
    <v-container fill-height>
      <v-layout row wrap align-center>
        <v-flex xs8 class="mx-auto">
          <v-btn
            dark
            fab
            medium
            color="green lighten-1"
            class="push_right"
            @click.stop="drawer = !drawer">
            <v-icon>settings</v-icon>
          </v-btn>
          <v-spacer></v-spacer>

            <v-flex xs6>
              <h1 class="display-1 sans_pro_medium fix-title-height pb-3">FBA Shipping Settings</h1>              
            </v-flex>          

            <v-flex xs6>
              <v-select
                required
                ref="marketplace"
                :items="marketplaces"
                label="Select your Amazon Marketplace"
                v-model="selected_marketplace"
                color="purple darken-3"
                prepend-icon="public"
              ></v-select>
            </v-flex>
            
            <v-tabs icons-and-text centered dark color="purple darken-3" class="elevation-12">
              <v-tabs-slider color="green lighten-1"></v-tabs-slider>
              
              <v-tab class="sans_pro_medium title" :key="standard">
                Standard
              </v-tab>

              <v-tab class="sans_pro_medium title" :key="priority" @click="setPriority" v-show="showThreeSpeeds">
                Priority
              </v-tab>

              <v-tab class="sans_pro_medium title" :key="expedited" @click="setExpedited">
                Expedited
              </v-tab>

              <v-tab-item :key="standard" >
                <standard_speed :selected_marketplace="selected_marketplace"></standard_speed>
              </v-tab-item>              

              <v-tab-item :key="priority">
                <priority_speed :selected_marketplace="selected_marketplace"></priority_speed>
              </v-tab-item>

              <v-tab-item :key="expedited">
                <expedited_speed :selected_marketplace="selected_marketplace"></expedited_speed>
              </v-tab-item>
              
            </v-tabs>
         </v-flex>
      
      <v-navigation-drawer
        v-model="drawer"
        absolute
        temporary
        right>
        
        <v-list>
          <v-list-tile>
            <v-list-tile-content>
              <v-list-tile-title class="title sans_pro">Settings & Help</v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
        </v-list>
        
        <v-divider></v-divider>
        
        <v-list dense>

          <v-list-tile @click="sendToCreds">  
            <v-list-tile-content>
              <v-list-tile-title class="subheading sans_pro">Amazon Credentials</v-list-tile-title>
            </v-list-tile-content>

            <v-list-tile-action>
              <v-icon color="purple darken-3">settings</v-icon>
            </v-list-tile-action>
          </v-list-tile>

          <v-list-tile @click="goToFAQ">  
            <v-list-tile-content>
              <v-list-tile-title class="subheading sans_pro">F.A.Q.</v-list-tile-title>
            </v-list-tile-content>

            <v-list-tile-action>
              <v-icon color="purple darken-3">help</v-icon>
            </v-list-tile-action>
          </v-list-tile>

          <v-list-tile @click="goToYouTube()">  
            <v-list-tile-content>
              <v-list-tile-title class="subheading sans_pro">Setup Videos</v-list-tile-title>
            </v-list-tile-content>

            <v-list-tile-action>
              <v-icon color="purple darken-3">ondemand_video</v-icon>
            </v-list-tile-action>
          </v-list-tile>
        </v-list>
      
      </v-navigation-drawer>
      
     </v-layout>
    </v-container>   
  </v-app>
</template>

<script>
import standard_speed from '../components/standard_speed.vue';
import priority_speed from '../components/priority_speed.vue';
import expedited_speed from '../components/expedited_speed.vue';
import {dataShare} from '../packs/application.js';
import axios from 'axios';

var url = "https://bc-only-rates-trimakas.c9users.io";

export default {
  data: function() {
    return {
      drawer: false,
      whereToGo: "amazon_credentials",
      showThreeSpeeds: true,
      selected_marketplace: "",
      marketplaces:[],
    };
  },
  components: {
    standard_speed,
    priority_speed,
    expedited_speed
  },
  created() {
    dataShare.$emit('speed', this.speed);
    let self = this;
    self.marketplaces = []
    axios.get(url + '/return_marketplaces').then(response => {
      response.data.forEach(function(element){
        self.marketplaces.push(element);
      });
    });
  },
  watch: {
    selected_marketplace: function(value) {
      if(value == "ATVPDKIKX0DER"){
        this.showThreeSpeeds = true;
      }
      else {
        this.showThreeSpeeds = false;
      }      
    }
  },
  methods: {
    goToFAQ() {
      window.open('http://bytestand.com/fba-shipping-faq/',
                  '_blank');
    },
    sendToCreds() {
      dataShare.$emit('whereToGo', this.whereToGo);
    },
    goToYouTube() {
     window.open('https://youtu.be/LAYEF6UvgAA',
            '_blank'); 
    }
  }
};
</script>

<style>

.lobster {
  font-family: 'Lobster Two', cursive !important;
  font-size: 25px !important;
}
 
.spacer {
    padding-bottom: 40px !important;
}
.push_right {
  float: right !important;
}
</style>