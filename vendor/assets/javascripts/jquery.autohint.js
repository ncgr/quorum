//
// jQuery autoHint
//
// v0.1.0
// Ken Seal hunzinker@gmail.com
// License: MIT

(function($) {

  var methods = {
  
    init: function() {
      return this.each(function() {
        var $this = $(this);
        $this.autoHint('addHints');
        $this.autoHint('focusHint');
        $this.autoHint('blurHint');
      });
    },

    // Add hints to the form elements.
    addHints: function() {
      return this.each(function() {
        var $this = $(this);
        if ($this.attr('title') === '') { 
          return; 
        }

        if ($this.val() === '') { 
          $this.val($this.attr('title')); 

          if (!$this.hasClass('auto-hint')) {
            $this.addClass('auto-hint');
          }
        } else { 
          $this.removeClass('auto-hint'); 
        }
      });          
    },

    // Remove hint and class on focus.
    focusHint: function() {
      return this.focus(function() {
        var $this = $(this);
        if ($this.val() === $this.attr('title')) {
          $this.val('');
          $this.removeClass('auto-hint');
        }
      });               
    },

    // Retain value or add hint.
    blurHint: function() {
      return this.blur(function() {
        var $this = $(this);
        if ($this.val() === '' && $this.attr('title') !== '') {
          $this.val($this.attr('title'));
          $this.addClass('auto-hint');
        }
      });     
    },
    
    // Remove hints on submit.
    removeHintsOnSubmit: function() {
      return this.each(function() {
        var $this = $(this);
        if ($this.val() === $this.attr('title')) { 
          $this.val(''); 
        }     
      });                      
    }

  };

  $.fn.autoHint = function(method) {

    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      $.error('Method ' +  method + ' does not exist for jQuery autoHint.');
    }      

  };

})(jQuery);
