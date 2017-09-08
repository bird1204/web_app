// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require s3_direct_upload
//= require lib/jquery.twzipcode.min
//= require magnific-popup
//= require menu
//= require members
//= require social-share-button
//= require social-share-button/wechat
//
// XXX due to webshim's bug. [ref](https://github.com/jelhan/croodle/commit/529c96420b15c7b6e1dab69b760ea1801e2e97ef)
if (typeof jQuery.swap !== 'function') {
    jQuery.swap = function( elem, options, callback, args ) {
        var ret, name, old = {};
        // Remember the old values, and insert the new ones
        for ( name in options ) {
            old[ name ] = elem.style[ name ];
            elem.style[ name ] = options[ name ];

        }

        ret = callback.apply( elem, args || [] );

        // Revert the old values
        for ( name in options ) {
            elem.style[ name ] = old[ name ];

        }
        return ret;

    };
}

window.addEventListener('DOMContentLoaded', function() {
  // webshim.setOptions
  webshim.setOptions("forms", {
      replaceValidationUI: true,
      customDatalist: "auto",
      addValidators: true
  });

  // request the features you need:
  webshim.polyfill('forms');
});

$(function() {
  var elements = document.querySelectorAll('input,select,textarea');
  for(var i = elements.length; i--;){
    elements[i].addEventListener('invalid',function(){
      this.scrollIntoView(false);
    });
  }
});

window.initTwZipCode = function () {
  return $('#twzipcode').twzipcode({
      'zipcodeIntoDistrict': true,
      'hideCounty': ['金門縣', '連江縣', '澎湖縣']
  });
};

$(document).ready(function(){
  $('.page').css('margin-top', Math.min($('.header').height(), 185))
})
