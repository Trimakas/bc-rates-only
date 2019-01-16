<template>
  <v-app>
    <credential_instructions class="no_background"></credential_instructions>
    <credential_details
      :amazonCredsArray="amazonCredsArray"
      @updateCredsArray="updateCredsArray"
      @addComponent="" 
      @removeComponent=""
      xs12
      class="no_background"
      >
    </credential_details>
    <v-container fluid grid-list-lg>
      <v-layout row wrap class="text-xs-center">
        <v-flex xs6>
          <v-btn
            @click="sendBackToSpeeds"
            block
            outline
            large 
            class="my_dark_purple_outline_btn negative_top_margin" 
            dark 
            >I'm Finished Entering Marketplaces
          </v-btn>
        </v-flex>
      </v-layout>
    </v-container>
  </v-app>  
</template>

<script>

import {dataShare} from '../packs/application.js';
import credential_instructions from '../components/credential_instructions.vue';
import credential_details from '../components/credential_details.vue';
import axios from 'axios';

var url = "https://bc-only-rates-trimakas.c9users.io";

export default {
  data: function() {
    return {
      amazonCredsArray: [],
      components: [],
    };
  },
  components: {
    credential_instructions,
    credential_details
  },
  methods: {
  updateCredsArray() {
    let self = this;
    self.amazonCredsArray = [];
    axios.get(url + "/return_amazon_credentials").then(response => {
      response.data.forEach(function(element) {
      self.amazonCredsArray.push(element);
      });
    }); 
  },
  sendBackToSpeeds() {
    dataShare.$emit('whereToGo', "speeds");
  },
  },
  created() {
    dataShare.$on('addComponent', (data) => {
      this.amazonCredsArray.push(data);
    });
    dataShare.$on('removeComponent', (data) => {
      this.amazonCredsArray.pop();
    });
    let self = this;
    axios.get(url + "/return_amazon_credentials").then(response => {
      response.data.forEach(function(element) {
        self.amazonCredsArray.push(element);
      });
    });
  }
};  

</script>

<style>

.my_dark_purple_outline_btn {
  background-color: #68007d !important;
  color: #68007d !important;
}

.negative_top_margin {
  margin-top: -35px !important;
}

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
  padding: 15px;
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