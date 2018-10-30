<template>
  <v-app>
    <credential_instructions class="no_background"></credential_instructions>
    <credential_details
      xs12
      class="no_background"
      id="amazon_credentials"
      v-for="(item, index) in components"
      :index="index"
      :key="'fourth' + index "
      :seller_id="seller_id"
      :selected_marketplace="selected_marketplace"
      :token="token"
      >
    </credential_details>
  </v-app>  
</template>

<script>
/*global top*/

import {dataShare} from '../packs/application.js';
import credential_instructions from '../components/credential_instructions.vue';
import credential_details from '../components/credential_details.vue';
import axios from 'axios';

var url = "https://bc-only-rates-trimakas.c9users.io";

export default {
  data: function() {
    return {
      seller_id: "",
      selected_marketplace: null,
      token: "",
      components: [],
    };
  },
  components: {
    credential_instructions,
    credential_details
  },
  created() {
    dataShare.$on('addComponent', (data) => {
      this.components.push(data);
    });
    dataShare.$on('removeComponent', (data) => {
      this.components.pop();
    });
    let self = this;
    axios.get(url + '/return_zone_info').then(response => {
      response.data.forEach(function(zone) {
        if(zone.selected){
          var zone_selected_hash = {text: zone.zone_name, value: zone.bc_zone_id};
          self.selected_zones.push(zone_selected_hash); 
        }
        var zone_hash = {text: zone.zone_name, value: zone.bc_zone_id};
        self.zones.push(zone_hash);
      });
    });
    axios.get(url + '/return_amazon_credentials').then(response => {
      // debugger;
      response.data.forEach(function(element){
        self.seller_id = element.seller_id;
        self.selected_marketplace = element.marketplace;      
        self.token = element.auth_token;
        self.components.push(1);
      });
      if(self.seller_id == ""){
        self.show_cancel_button = false;
      }
      self.show_cancel_button;
    });
  }
};  

</script>

<style>

.dark-green-button {
  background-color: #43A047 !important;
}

.green-font {
  color: #43A047 !important;
}

.red-font {
  color: #E53935 !important;
}

.full-height .flex{
  display: flex !important; 
}

.full-height .flex > .card{
 flex: 1 1 auto !important; 
}
    

.textfield-background-beige {
  background-color: #f7f1ec !important;
}

.theme--light .input-group input:disabled {
  color: rgba(0,0,0,.87) !important;
}
  
.lightbeige {
  background-color: #f1e7df !important;
}

.lightblue {
  background-color: #d9d6e1 !important;
}

.lightpurple {
  background-color: #e9daea !important;
}

.match-to-text-field {
  margin-left: -17px !important;
  height: 46px !important;
  margin-top: 2px !important;
}
</style>