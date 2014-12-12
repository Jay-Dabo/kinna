/**
 * Created by mhn on 2014-12-07.
 */
var app= angular.module('kinna', ["ui.bootstrap", 'ngLocale']);
$(document).on('ready page:load', function () {
    angular.bootstrap(document.body, ['kinna']);
});