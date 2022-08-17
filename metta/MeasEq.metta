;; The symbol ≞, called Measured By in Unicode, and \measeq in LaTeX,
;; is used to represent the measure of an event.  This measure may be
;; boolean, probabilistic (first or second order), evidential or
;; otherwise.  The idea is to not conflate event and measure to avoid
;; downstream contradictions.

;; Define ≞ as a dependent type.
(: ≞ (-> Atom TruthValue Type))
