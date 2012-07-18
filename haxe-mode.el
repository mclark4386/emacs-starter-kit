;;; haxe-mode.el --- actionscript mode derived from cc-mode

;; Author:     2009 David Bergman
;; Maintainer: David Bergman <davber at gmail dot com>
;; Created:    April 2009
;; 
;; This is a simple alteration of an ActionScript mode created
;; by John Connors (it should be found at http://www.emacswiki.org/emacs/ActionScriptMode)
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:


;; Note: The interface used in this file requires CC Mode 5.30 or
;; later.

;;; Code:

(require 'cc-mode)

;; These are only required at compile time to get the sources for the
;; language constants.  (The cc-fonts require and the font-lock
;; related constants could additionally be put inside an
;; (eval-after-load "font-lock" ...) but then some trickery is
;; necessary to get them compiled.)
(eval-when-compile
  (require 'cc-langs)
  (require 'cc-fonts))

(eval-and-compile
  ;; Make our mode known to the language constant system.  Use Java
  ;; mode as the fallback for the constants we don't change here.
  ;; This needs to be done also at compile time since the language
  ;; constants are evaluated then.
  (c-add-language 'haxe-mode 'java-mode))

; Constants
(c-lang-defconst c-constant-kwds 
  haxe
  '("true" "false" "null"))

;; actionscript has no boolean but a string and a vector type.
(c-lang-defconst c-primitive-type-kwds
  haxe
   '("Dynamic" "Bool" "Int" "Null" "Float" "String" "Void" 
     "Object" "Array" "List" "Date" "Error" "XML" "XMLList" ))

;; Keywords introducing other declaration-level constructs.
(c-lang-defconst c-other-decl-kwds
	haxe
    '("import"))

;; Statement keywords followed directly by a block.
(c-lang-defconst c-block-stmt-1-kwds
  haxe
  '("do" "else" "finally" "try"))

(c-lang-defconst c-block-stmt-2-kwds
  haxe
  '("for" "if" "while" "switch" "catch"))
;;; 
;; Statement keywords followed by an expression or nothing.
(c-lang-defconst c-simple-stmt-kwds
  haxe
  '("break" "continue" "return" "throw"))

(c-lang-defconst c-class-decl-kwds
  haxe
  '("class" "interface"))

(c-lang-defconst c-opt-cpp-prefix
  haxe
  "\\s *\\[\\s *")

(c-lang-defconst c-opt-ccp-include-directives
  haxe
  '())

;; Function declarations begin with "function" in this language.
;; There's currently no special keyword list for that in CC Mode, but
;; treating it as a modifier works fairly well.
(c-lang-defconst c-modifier-kwds
  haxe 
 '("function" "public" "private" "inline" "override" "extern" "static"))


(c-lang-defconst c-other-block-decl-kwds
  haxe
  '("package"))

(c-lang-defconst c-typeless-decl-kwds
  haxe
  '("var"))

(c-lang-defconst c-primary-expr-kwds
  haxe
  '("super" "this"))

(c-lang-defconst c-other-kwds
  haxe
  '("delete" "get" "set" "with"))

(defgroup haxe nil
  "Major mode for editing haXe code."
  :group 'languages
  :prefix "haxe-")

(defcustom haxe-mode-hook nil
  "Hook for customizing `haxe-mode'."
  :group 'haxe
  :type 'hook)

(defcustom haxe-font-lock-extra-types nil
  "*List of extra types (aside from the type keywords) to recognize in haXe mode.
Each list item should be a regexp matching a single identifier.")

(defconst haxe-font-lock-keywords-1 
  (c-lang-const c-matchers-1 haxe)
  "Minimal highlighting for haXe mode.")

(defconst haxe-font-lock-keywords-2 
  (c-lang-const c-matchers-2 haxe)
  "Fast normal highlighting for haXe mode.")

(defconst haxe-font-lock-keywords-3 
  (c-lang-const c-matchers-3 haxe)
  "Accurate normal highlighting for haXe mode.")

(defvar haxe-font-lock-keywords haxe-font-lock-keywords-3
  "Default expressions to highlight in haXe mode.")

(defvar haxe-mode-syntax-table nil
  "Syntax table used in haxe-mode buffers.")
(or haxe-mode-syntax-table
    (setq haxe-mode-syntax-table
      (funcall (c-lang-const c-make-mode-syntax-table haxe))))

(defvar haxe-mode-abbrev-table nil
  "Abbreviation table used in haxe-mode buffers.")

(c-define-abbrev-table 'haxe-mode-abbrev-table
  ;; Keywords that if they occur first on a line might alter the
  ;; syntactic context, and which therefore should trig reindentation
  ;; when they are completed.
  '(("else" "else" c-electric-continued-statement 0)
    ("while" "while" c-electric-continued-statement 0)))

(defvar haxe-mode-map (let ((map (c-make-inherited-keymap)))
              ;; Add bindings which are only useful for haXe
              map)
  "Keymap used in haxe-mode buffers.")

(easy-menu-define haxe-menu haxe-mode-map "haXe Mode Commands"
          ;; Can use `haxe' as the language for `c-mode-menu'
          ;; since its definition covers any language.  In
          ;; this case the language is used to adapt to the
          ;; nonexistence of a cpp pass and thus removing some
          ;; irrelevant menu alternatives.
          (cons "HAXE" (c-lang-const c-mode-menu haxe)))

;;;###Autoload
(add-to-list 'auto-mode-alist '("\\.hx\\'" . haxe-mode))

;;;###autoload
(defun haxe-mode ()
  "Major mode for editing haXe. hAxe is what Actionscript should have been.
 
The hook `c-mode-common-hook' is run with no args at mode
initialization, then `haxe-mode-hook'.

Key bindings:
\\{haxe-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (c-initialize-cc-mode t)
  (set-syntax-table haxe-mode-syntax-table)
  (setq major-mode 'haxe-mode
    mode-name "haXe"
    local-abbrev-table haxe-mode-abbrev-table
    abbrev-mode t)
  (use-local-map c-mode-map)
  ;; `c-init-language-vars' is a macro that is expanded at compile
  ;; time to a large `setq' with all the language variables and their
  ;; customized values for our language.
  (c-init-language-vars haxe-mode)
  ;; `c-common-init' initializes most of the components of a CC Mode
  ;; buffer, including setup of the mode menu, font-lock, etc.
  ;; There's also a lower level routine `c-basic-common-init' that
  ;; only makes the necessary initialization to get the syntactic
  ;; analysis and similar things working.
  (c-common-init 'haxe-mode)
  (easy-menu-add haxe-menu)
  (run-hooks 'c-mode-common-hook)
  (run-hooks 'haxe-mode-hook)
  (c-update-modeline))

 
(provide 'haxe-mode)
