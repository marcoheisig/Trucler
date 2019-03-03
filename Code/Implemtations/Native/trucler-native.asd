(cl:in-package #:asdf-user)

(defsystem "trucler-native"
  :depends-on ("trucler-base")
  :serial t
  :components
  ((:file "packages")
   (:file "environment")
   (:file "query-methods")
   (:file "low-level-augmentation-methods")
   (:file "augmentation-methods")))
