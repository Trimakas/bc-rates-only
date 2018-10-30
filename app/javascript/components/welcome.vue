<template>
  <v-app>  
    <v-container fill-height>
      <v-layout row wrap align-center class="text-xs-center">
        <v-flex align-center xs6 v-show="['lg', 'xl'].includes(size)" class="mx-auto">
          <v-img flex :height="imageHeight" :width="imageHeight" src="rose.png">
            <v-container fill-height>
              <v-layout align-center>
                <v-flex xs12 text-xs-center>
                  <h1 class="display-1 oswald my_light_purple_text mt-3">Welcome to</h1>
                  <h1 class="display-2 my_dark_purple_text oswald">FBA Rates</h1>
                  <h1 class="subheading mont mt-2">Real time Amazon FBA Rates</h1>
                  <h1 class="subheading mont">for multiple marketplaces</h1>
                  <v-btn @click="sendToAmazonCreds()" large class="mt-3 my_dark_purple_btn">Let's Get Started!</v-btn>                  
                </v-flex>
              </v-layout>
            </v-container>
          </v-img>
        </v-flex>
        
        <v-flex align-center xs6 v-show="['md'].includes(size)" class="mx-auto">
          <v-img flex :height="imageHeight" :width="imageHeight" src="rose_400.png">
            <v-container fill-height>
              <v-layout align-center>
                <v-flex xs12 text-xs-center>
                  <h1 class="headline oswald my_light_purple_text mt-3">Welcome to</h1>
                  <h1 class="display-1 my_dark_purple_text oswald">FBA Rates</h1>
                  <h1 class="body-2 mont mt-2">Real time Amazon FBA Rates</h1>
                  <h1 class="body-2 mont">for multiple marketplaces</h1>
                  <v-btn @click="sendToAmazonCreds()" large class="mt-3 my_dark_purple_btn">Let's Get Started!</v-btn>
                </v-flex>
              </v-layout>
            </v-container>
          </v-img>
        </v-flex>
        
        <v-flex align-center sm8 xs12 v-show="['sm', 'xs'].includes(size)" class="mx-auto">
          <v-img flex :height="imageHeight" :width="imageHeight" src="rose_325.png">
            <v-container fill-height>
              <v-layout align-center>
                <v-flex text-xs-center>
                  <h1 class="headline oswald my_light_purple_text mt-3">Welcome to</h1>
                  <h1 class="display-1 my_dark_purple_text oswald">FBA Rates</h1>
                  <h1 class="body-1 mont mt-2">Real time Amazon FBA Rates </h1>
                  <h1 class="body-1 mont">for multiple marketplaces</h1>
                  <v-btn @click="sendToAmazonCreds()" small class="mt-1 my_dark_purple_btn">Let's Go!</v-btn>
                </v-flex>
              </v-layout>
            </v-container>
          </v-img>
        </v-flex>
      </v-layout>
    </v-container>
  </v-app>
</template>


<script>
import {dataShare} from '../packs/application.js'
import axios from 'axios';
import amazon_credentials from '../components/amazon_credentials.vue';

var url = "https://bc-only-rates-trimakas.c9users.io";

export default {
  data: function() {
    return {
      size: "",
      whereToGo: "amazon_credentials"
    }
  },
  methods: {
    sendToAmazonCreds() {
      dataShare.$emit('whereToGo', this.whereToGo);
    },
    setupUninstallHook() {
      axios.post(url + '/setup_uninstall_webhook');
    }
  },
  computed: {
    imageHeight() {
      console.log("the screen size is " + this.$vuetify.breakpoint.name);
      this.size = this.$vuetify.breakpoint.name;
      switch (this.size) {
        case 'xs': return '450px';
        case 'sm': return '475px';
        case 'md': return '500px';
        case 'lg': return '540px';
        case 'xl': return '540px';
     }
   },
  }
};

</script>

<style>

.filled_dot {
  height: 20px;
  width: 20px;
  border-color: #68007d;
  border-style: solid;
  border-width: 2px;
  background-color: #68007d;
  border-radius: 50%;
  display: inline-block;
}


.dot {
  height: 20px;
  width: 20px;
  border-color: #68007d;
  border-style: solid;
  border-width: 2px;
  border-radius: 50%;
  display: inline-block;
}

.spacer {
  padding-top: 20px;
  padding-bottom: 20px;
}

.oswald {
  font-family: 'Oswald', sans-serif !important;
}

.mont {
  font-family: 'Montserrat', sans-serif !important;
}

.no_background {
  background: transparent !important;
}

.my_dark_purple_btn {
  background-color: #68007d !important;
  color: white !important;
}

.my_dark_purple_text {
  color: #68007d !important;
}

.my_light_purple_text {
  color: #911da9 !important;
}

</style>