(cl:in-package #:trucler-native)

;;; Return the value of KEY in ALIST, or NIL.
(defun alist-value (key alist &optional (default nil))
  (let ((cons-or-nil (assoc key alist)))
    (if (null cons-or-nil)
        default
        (cdr cons-or-nil))))

(defun leaf-type (leaf env)
  (sb-kernel:type-specifier
   (sb-kernel:type-intersection
    (sb-c::leaf-type leaf)
    (or (alist-value leaf (sb-c::lexenv-type-restrictions env))
        sb-kernel:*universal-type*))))

(defun leaf-dynamic-extent (leaf env)
  (declare (ignore env))
  (and (sb-c::leaf-dynamic-extent leaf) t))

(defmethod trucler:describe-variable (client (env sb-kernel:lexenv) name)
  (let ((var (alist-value name (sb-c::lexenv-vars env))))
    (etypecase var
      (sb-c::lambda-var
       (make-instance 'sbcl-lexical-variable-description
         :name name
         :identity nil
         :dynamic-extent (leaf-dynamic-extent var env)
         :ignore (sb-c::lambda-var-ignorep var)
         :type (leaf-type var env)))
      (sb-c::global-var
       (ecase (sb-c::global-var-kind var)
         (:special
          (make-instance 'sbcl-global-special-variable-description
            :name name
            :type (leaf-type var env)
            :dynamic-extent (leaf-dynamic-extent var env)))
         (:global
          (make-instance 'sbcl-global-variable-description
            :name name
            :type (leaf-type var env)
            :dynamic-extent (leaf-dynamic-extent var env)))
         (:unknown nil)))
      (sb-c::constant
       (make-instance 'sbcl-constant-variable-description
         :name name
         :type (leaf-type var env)
         ))
      (cons
       (make-instance 'sbcl-local-symbol-macro-description
         :name name
         :expansion var))
      (null
       (ecase (sb-int:info :variable :kind name)
         (:special
          (make-instance 'sbcl-global-special-variable-description
            :name name))
         (:macro
          (make-instance 'sbcl-global-symbol-macro-description
            :name name))
         (:unknown nil))))))

(defmethod trucler:describe-function (client (environment sb-kernel:lexenv) name)
  )

(defmethod trucler:describe-block (client (environment sb-kernel:lexenv) name)
  )

(defmethod trucler:describe-tag (client (environment sb-kernel:lexenv) tag)
  )

#+nil
(defmethod trucler:describe-class (client (environment sb-kernel:lexenv) clas-name)
  )

(defmethod trucler:describe-optimize (client (environment sb-kernel:lexenv))
  )
