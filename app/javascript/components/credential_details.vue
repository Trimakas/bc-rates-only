<template>
    <v-container fluid grid-list-lg class="come_closer">
      <v-layout row wrap>
        <v-flex xs12 v-for="(creds, index) in amazonCredsArray" :key="creds.id" class="pb-4">
          <v-card class="lightpurple">
            <v-card-title>
              <v-icon class="my_dark_purple_text">language</v-icon>
              <h1 class="title oswald my_dark_purple_text pl-2 pr-5">ENTER YOUR AMAZON CREDENTIALS BELOW</h1>
            </v-card-title>

         <v-form ref="form" lazy-validation>
            <v-layout xs12 row wrap class="mx-auto" >
              <v-flex xs12>
                <v-text-field
                  ref="seller_id"
                  :rules="[ v => sellerIdRules(v, index) ]"
                  validate-on-blur
                  required
                  color="indigo"
                  label="Amazon Seller Id"
                  v-model="creds.seller_id"
                  prepend-icon="person"
                ></v-text-field>
              </v-flex>
              
              <v-flex xs12>
                <v-select
                  required
                  ref="marketplace"
                  :rules="[ v => marketplaceRules(v, index) ]"
                  validate-on-blur  
                  :items="marketplaces"
                  label="Select your Amazon Marketplace"
                  v-model="creds.marketplace"
                  color="indigo"
                  prepend-icon="map"
                ></v-select>
              </v-flex>

              <v-flex xs12>
                <v-text-field
                  required
                  ref="auth_token"
                  :rules="[ v => authTokenRules(v, index) ]"
                  validate-on-blur
                  color="indigo"
                  id="testing"
                  name="input-1"
                  label="Amazon Auth Token"
                  v-model="creds.auth_token"
                  prepend-icon="https"
                ></v-text-field>
              </v-flex>

              <v-flex xs12>
                <v-select
                  required
                  ref="zones"
                  :rules="[ v => zoneRules(v, index) ]"
                  validate-on-blur
                  color="indigo"
                  :items="zones"
                  label="Select which zone(s) you would like to add this rate too"
                  v-model="creds.zones"
                  prepend-icon="public"
                  multiple
                  chips
                  deletable-chips
                  return-object
                ></v-select>
              </v-flex>
              
              <v-flex>
                <v-layout row wrap class="text-xs-center" v-if="show_cancel_button">
                  <v-flex xs6>
                    <v-btn
                      :id="creds.id"
                      block 
                      large 
                      class="my_dark_purple_btn" 
                      dark 
                      @click="formCheckAndSave($refs.form, index)"
                      :class="{looks_disabled: buttonDisabledIndex.includes(index) }"
                      >{{ buttonDisabledIndex.includes(index) ? "Please fix the above details" : "Update Your Credentials" }}
                    </v-btn>
                  </v-flex>
                  <v-flex xs6>
                    <v-btn block outline large color="indigo" dark @click="sendBackToSpeeds">Cancel</v-btn>
                  </v-flex>
                </v-layout>
              
                <v-layout row wrap class="text-xs-center" v-else>
                  <v-flex xs12>
                    <v-btn
                      :id="creds.id"
                      block 
                      large 
                      :class="{looks_disabled: buttonDisabledIndex.includes(index) }"
                      dark 
                      @click="formCheckAndSave($refs.form, index)"
                      >{{ buttonDisabledIndex.includes(index) ? "Please fix the above details" : "Save Your Credentials" }}
                    </v-btn>
                  </v-flex>
                </v-layout>
                
                <v-layout row wrap class="text-xs-center" :key="creds.id">
                  <v-flex mb-3 class="fullLayoutorHalf(amazonCredsArray)">
                    <v-btn fab dark large mb-3 color="green" @click="addCounter()">
                      <v-icon dark>add</v-icon>
                    </v-btn>
                    <h1 class="title oswald my_dark_purple_text">Add additional marketplaces</h1>
                  </v-flex>
                  
                  <v-flex xs6 mb-3 v-show="amazonCredsArray.length > 1">
                    <v-btn fab dark large mb-3 color="red" @click="removeCounter(), removeAmazonCreds($refs.seller_id, $refs.marketplace, $refs.auth_token, index)">
                      <v-icon dark>remove</v-icon>
                    </v-btn>
                    <h1 class="title oswald my_dark_purple_text">Remove marketplace</h1>
                  </v-flex>
                </v-layout>
              </v-flex>
              
              </v-layout>
            </v-form>
          </v-card>
        </v-flex>
        
        <div class="text-xs-center">
          <v-bottom-sheet inset v-model="error_sheet">
            <v-card dark color="red darken-1">
              <v-card-title>
                <h1 v-if="credentials_bad" key="bad_creds" class="headline pb-2 oswald mx-auto">{{bad_credentials}}</h1>
                <h1 v-if="credentials_bad" key="video" class="title oswald mx-auto">{{watch_video}}</h1>
              </v-card-title>
            </v-card>  
          </v-bottom-sheet>
        </div>
        
        <div class="text-xs-center">
          <v-bottom-sheet inset v-model="success_sheet">
            <v-card dark color="green">
              <v-card-title>
                <h1 key="good_creds" class="headline pb-2 oswald mx-auto">{{good_credentials}}</h1>
              </v-card-title>
            </v-card>  
          </v-bottom-sheet>
        </div>
  
      </v-layout>
      
      
    </v-container>
</template>

<script>

import {dataShare} from '../packs/application.js';
import axios from 'axios';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';

var url = "https://bc-only-rates-trimakas.c9users.io";

export default {
  mixins: [validationMixin],
  props: ["amazonCredsArray"],
  data: function() {
    return {
      buttonDisabledIndex: [],
      validButtonText: "Update Your Credentials",
      disabledButtonText: "Please fix the above credentials",
      show_cancel_button: true,
      credentials_bad: false,
      bad_credentials: "Oh no! Your Amazon credentials aren't right. Can you try again?",
      watch_video: "Make sure to watch our video in the top right hand corner",
      good_credentials: "Great job! You've successfully saved your credentials!",
      error_sheet: false,
      success_sheet: false,
      selected_zones: [],
      seller_id: "",
      marketplace: "",
      auth_token: "",
      zones: [],
      counter: 1,
      subtractor: 1,
      marketplaces:[
          { text: 'Australia', value: "A39IBJ37TRP1C6" },
          { text: 'Canada', value: "A2EUQ1WTGCTBG2" },
          { text: 'France', value: "A13V1IB3VIYZZH" },
          { text: 'Germany', value: "A1PA6795UKMFR9" },
          { text: 'Italy', value: "APJ6JRA9NG5V4" },
          { text: 'Mexico', value: "A1AM78C64UM0Y8" },
          { text: 'Spain', value: "A1RKKUPIHCS9HS" },
          { text: 'United Kingdom', value: "A1F83G8C2ARO7P" },
          { text: 'United States', value: "ATVPDKIKX0DER" },          
        ],
    };
  },
  created() {
    let self = this;
    axios.get(url + '/return_zone_info').then(response => {
      response.data.forEach(function(zone) {
        var zone_hash = {text: zone.zone_name, value: zone.bc_zone_id};
        self.zones.push(zone_hash);
      });
    });
  },
  methods: {
  fullLayoutorHalf(amazonCredsArray) {
    if(amazonCredsArray.length == 1){
      return "xs12";
    }
    else {
      return "xs6";
    }
  },
  zoneRules(value, index) {
    if (typeof value == 'undefined' || value.length == 0) {
        this.buttonDisabledIndex.push(index);
        return "Please select at least one zone";
    } else {
        var buttonIndex = this.buttonDisabledIndex.indexOf(index);
        this.buttonDisabledIndex.splice(buttonIndex,1);
        this.selected_zones = value;
        return true;
    }    
  },   
  authTokenRules(value, index) {
    if (typeof value == 'undefined' || value.length == 0) {
        this.buttonDisabledIndex.push(index);
        return "Please provide your Amazon auth token";
    } else {
        var buttonIndex = this.buttonDisabledIndex.indexOf(index);
        this.buttonDisabledIndex.splice(buttonIndex,1)
        this.auth_token = value;
        return true;
    }    
  },  
  marketplaceRules(value, index) {
    if (typeof value == 'undefined' || value.length == 0) {
      this.buttonDisabledIndex.push(index);
      return "Please select an Amazon Marketplace";  
    } else {
        var buttonIndex = this.buttonDisabledIndex.indexOf(index);
        this.buttonDisabledIndex.splice(buttonIndex,1)
        this.marketplace = value;
        return true;
    }    
  },  
  sellerIdRules(value, index) {
    if (typeof value == 'undefined' || value.length == 0) {
        this.buttonDisabledIndex.push(index);
        return "Please provide your Amazon Seller ID";  
    } else {
        var buttonIndex = this.buttonDisabledIndex.indexOf(index);
        this.buttonDisabledIndex.splice(buttonIndex,1);
        this.seller_id = value;
        return true;
    }
    },
    formCheckAndSave(form, index) {
      if(index > 0) {
        var amazonCreds = {}
          amazonCreds = {
            seller_id: this.seller_id,
            marketplace: this.marketplace,
            auth_token: this.auth_token,
            zones: this.selected_zones
          };
      }
      else{
        var amazonCreds = this.amazonCredsArray[index]
      }
      if(form[index].validate()) {
        this.sendAmazonCreds(amazonCreds);
      }
    },
    allDone(form, index){
      if(form[index].validate()) {
        dataShare.$emit('whereToGo', "speeds"); 
      }
    },
    sendBackToSpeeds() {
      dataShare.$emit('whereToGo', "speeds");
    },
    removeCounter() {
      dataShare.$emit('removeComponent', this.subtractor);
    },
    addCounter() {
      this.counter++;
      dataShare.$emit('addComponent', this.counter);
    },
    removeAmazonCreds(seller_id, marketplace, auth_token, index) {
        var amazonCreds = {}
        amazonCreds = {seller_id: seller_id[index].value,
                      marketplace: marketplace[index].value,
                      auth_token: auth_token[index].value};
        axios.post(url + '/remove_amazon_credentials', amazonCreds).then(response => {
          console.log("well that worked");
        });
      // }  
    },
    sendAmazonCreds(amazonCreds) {
      let self = this;
      axios.post(url + '/amazon_credentials_check', amazonCreds).then(response => {
        var creds_status = response.data.are_the_amazon_creds_good;
        if(creds_status == true){
          self.success_sheet = true;
          self.sendZones(amazonCreds);
        }
        if(creds_status == false){
          self.error_sheet = true;
          self.credentials_bad = true;
        }
      });
    },
    sendZones(amazonCreds) {
      axios.post(url + '/receive_zone_info', amazonCreds); 
    }
  }
};  

</script>

<style>

.looks_disabled {
  background-color: rgba(0,0,0,.54) !important;
  pointer-events: none !important;
  box-shadow: none!important;
}

.chip__content {
  background-color: #273a8a !important;
  color: white !important;
}

.come_closer {
   margin-top: -15px !important; 
}
</style>