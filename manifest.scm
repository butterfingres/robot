(use-modules (gnu packages base)
             (gnu packages check)
             (gnu packages embedded)
             (gnu packages file)
             (gnu packages python-build)
             (gnu packages python-check)
             (gnu packages python-web)
             (gnu packages python-xyz)
             (guix build-system gnu)
             (guix build-system pyproject)
             (guix download)
             (guix gexp)
             (guix git-download)
             ((guix licenses) #:prefix license:)
             (guix packages)
             (guix store))

(define arm-none-eabi-toolchain
  (make-arm-none-eabi-toolchain-12.3.rel1))

(define pros-2
  (package
   (name "pros")
   (version "2.12.2")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/purduesigbots/pros.git")
           (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "061jqvhv3n0lp52hs06mm4qgr2wk85nlbnvl4hxzwslpq2zwkscr"))))
   (build-system gnu-build-system)
   (inputs (list file))
   (arguments `(#:make-flags '("bin/libpros.a")
                #:tests? #f
                #:phases ,#~(modify-phases %standard-phases
                              (replace 'configure
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (substitute* "common.mk"
                                    (("\\/bin\\/echo")
                                     #$(file-append coreutils "/bin/echo")))))
                              (replace 'install
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (rename-file "bin/libpros.a.public" "bin/libpros.a")
                                  (let* ((root (string-append #$output "/arm-none-eabi")))
                                    (install-file "bin/libpros.a" (string-append root "/lib"))
                                    (copy-recursively "include" (string-append root "/include"))))))))

   (native-inputs (list arm-none-eabi-toolchain))
   (home-page "https://pros.cs.perdue.edu")
   (synopsis "Kernel for the Vex Cortex 2.0.")
   (description
    "PROS is a lightweight and fast alternative open source operating
system for the VEX Cortex Microcontroller. It features multitasking,
low-level control, and Wiring compatible functions to harness the full
power of the Cortex. PROS is built with developers in mind and with a
focus on providing an environment for industry-applicable experience.")
   (license license:mpl2.0)))

(define-public python-observable
  (package
    (name "python-observable")
    (version "1.0.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/timofurrer/observable")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1q3mark0lkv9izzfyr223x5zz23wwrlggjwnsr4n75vp53qcxcnb"))))
    (arguments (list
                #:tests? #f
                #:phases #~(modify-phases %standard-phases
                             (add-after 'unpack 'fix-deprecation
                                        (lambda* (#:key outputs #:allow-other-keys)
                                          (substitute* "setup.py"
                                            (("License :: OSI Approved :: MIT License")
                                             "MIT")))))))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/timofurrer/observable")
    (synopsis "minimalist event system")
    (description "minimalist event system.")
    (license license:expat)))

(define-public python-cobs
  (package
    (name "python-cobs")
    (version "1.2.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "cobs" version))
       (sha256
        (base32 "1nlqrarg68c2hz3646dcn4lwcsndblhnkhnhhdpphwhx24r5xpfv"))))
    (arguments
     (list #:tests? #f))
    (build-system pyproject-build-system)
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/cmcqueen/cobs-python")
    (synopsis "Consistent Overhead Byte Stuffing (COBS)")
    (description "Consistent Overhead Byte Stuffing (COBS).")
    (license license:expat)))

(define-public python-rich-click-1.7
  (package
    (name "python-rich-click")
    (version "1.7.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ewels/rich-click")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1h13rcc6py3fjm518q2wbgmz5yb17cs8s2ixjh17w7ncx8v73aks"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f))
    (propagated-inputs (list python-click-8.1 python-rich python-typing-extensions))
    (native-inputs (list python-flake8-docstrings python-packaging
                         python-pytest python-types-setuptools
                         python-setuptools))
    (home-page "https://github.com/ewels/rich-click")
    (synopsis "Format click help output nicely with rich")
    (description "Click is a \"Python package for creating beautiful command
line interfaces\".  Rich is a \"Python library for rich text and beautiful
formatting in the terminal\".  The intention of rich-click is to provide
attractive help output from click, formatted with rich, with minimal
customization required.")
    (license license:expat)))

(define-public python-pypng-0.0.20
  (package
    (name "python-pypng")
    (version "0.0.20")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "pypng" version))
       (sha256
        (base32 "02qpa22ls41vwsrzw9r9qhj1nhq05p03hb5473pay6y980s86chh"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases #~(modify-phases %standard-phases
                   (add-after 'unpack 'fix-license
                              (lambda* (#:key outputs #:allow-other-keys)
                                (substitute* "setup.py"
                                  (("License :: OSI Approved :: MIT License")
                                   "MIT")))))))
    (native-inputs (list python-setuptools))
    (home-page "https://gitlab.com/drj11/pypng")
    (synopsis "Pure Python library for saving and loading PNG images")
    (description "Pure Python library for saving and loading PNG images.")
    (license license:expat)))

(define-public pros-cli
  (package
   (name "pros-cli")
   (version "3.5.6")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/purduesigbots/pros-cli.git")
           (commit version)))
     (patches (list (plain-file "pros-cli-fix-build.patch"
                                "diff --git a/pros/common/sentry.py b/pros/common/sentry.py
index 6c0c869..1de2b2c 100644
--- a/pros/common/sentry.py
+++ b/pros/common/sentry.py
@@ -5,7 +5,6 @@ import click
 import pros.common.ui as ui
 
 if TYPE_CHECKING:
-    from sentry_sdk import Client, Hub, Scope  # noqa: F401, flake8 issue with \"if TYPE_CHECKING\"
     import jsonpickle.handlers  # noqa: F401, flake8 issue, flake8 issue with \"if TYPE_CHECKING\"
     from pros.config.cli_config import CliConfig  # noqa: F401, flake8 issue, flake8 issue with \"if TYPE_CHECKING\"
 
@@ -97,20 +96,12 @@ def add_context(obj: object, override_handlers: bool = True, key: str = None) ->
     if override_handlers:
         jsonpickle.handlers.register(BaseTemplate, TemplateHandler, base=True)
 
-    from sentry_sdk import configure_scope
-    with configure_scope() as scope:
-        scope.set_extra((key or obj.__class__.__qualname__), jsonpickle.pickler.Pickler(unpicklable=False).flatten(obj))
-
     if override_handlers:
         jsonpickle.handlers.unregister(BaseTemplate)
 
 
 def add_tag(key: str, value: str):
-    from sentry_sdk import configure_scope
-
-    with configure_scope() as scope:
-        scope.set_tag(key, value)
-
+    pass
 
 def register(cfg: Optional['CliConfig'] = None):
     global cli_config, client
@@ -125,18 +116,5 @@ def register(cfg: Optional['CliConfig'] = None):
     if cli_config.offer_sentry is False:
         return
 
-    import sentry_sdk as sentry
-    from pros.upgrade import get_platformv2
-
-    client = sentry.Client(
-        'https://00bd27dcded6436cad5c8b2941d6a9d6@sentry.io/1226033',
-        before_send=prompt_to_send,
-        release=ui.get_version()
-    )
-    sentry.Hub.current.bind_client(client)
-
-    with sentry.configure_scope() as scope:
-        scope.set_tag('platformv2', get_platformv2().name)
-
 
 __all__ = ['add_context', 'register', 'add_tag']
diff --git a/pros/common/ui/__init__.py b/pros/common/ui/__init__.py
index 24fcc71..12241bd 100644
--- a/pros/common/ui/__init__.py
+++ b/pros/common/ui/__init__.py
@@ -2,7 +2,7 @@ import threading
 
 import jsonpickle
 from click._termui_impl import ProgressBar as _click_ProgressBar
-from sentry_sdk import add_breadcrumb
+# from sentry_sdk import add_breadcrumb
 
 from ..utils import *
 
@@ -26,7 +26,7 @@ def _machine_notify(method: str, obj: Dict[str, Any], notify_value: Optional[int
 
 def echo(text: Any, err: bool = False, nl: bool = True, notify_value: int = None, color: Any = None,
          output_machine: bool = True, ctx: Optional[click.Context] = None):
-    add_breadcrumb(message=text, category='echo')
+    # add_breadcrumb(message=text, category='echo')
     if ismachineoutput(ctx):
         if output_machine:
             return _machine_notify('echo', {'text': str(text) + ('\n' if nl else '')}, notify_value)
@@ -37,7 +37,7 @@ def echo(text: Any, err: bool = False, nl: bool = True, notify_value: int = None
 def confirm(text: str, default: bool = False, abort: bool = False, prompt_suffix: bool = ': ',
             show_default: bool = True, err: bool = False, title: AnyStr = 'Please confirm:',
             log: str = None):
-    add_breadcrumb(message=text, category='confirm')
+    # add_breadcrumb(message=text, category='confirm')
     if ismachineoutput():
         from pros.common.ui.interactive.ConfirmModal import ConfirmModal
         from pros.common.ui.interactive.renderers import MachineOutputRenderer
@@ -47,7 +47,7 @@ def confirm(text: str, default: bool = False, abort: bool = False, prompt_suffix
     else:
         rv = click.confirm(text, default=default, abort=abort, prompt_suffix=prompt_suffix,
                            show_default=show_default, err=err)
-    add_breadcrumb(message=f'User responded: {rv}')
+    # add_breadcrumb(message=f'User responded: {rv}')
     return rv
 
 
diff --git a/pros/common/utils.py b/pros/common/utils.py
index 294da89..11217bc 100644
--- a/pros/common/utils.py
+++ b/pros/common/utils.py
@@ -10,38 +10,8 @@ import click
 import pros
 
 
-@lru_cache(1)
 def get_version():
-    try:
-        ver = open(os.path.join(os.path.dirname(__file__), '..', '..', 'version')).read().strip()
-        if ver is not None:
-            return ver
-    except:
-        pass
-    try:
-        if getattr(sys, 'frozen', False):
-            import _constants
-            ver = _constants.CLI_VERSION
-            if ver is not None:
-                return ver
-    except:
-        pass
-    try:
-        import pkg_resources
-    except ImportError:
-        pass
-    else:
-        import pros.cli.main
-        module = pros.cli.main.__name__
-        for dist in pkg_resources.working_set:
-            scripts = dist.get_entry_map().get('console_scripts') or {}
-            for script_name, entry_point in iter(scripts.items()):
-                if entry_point.module_name == module:
-                    ver = dist.version
-                    if ver is not None:
-                        return ver
-    raise RuntimeError('Could not determine version')
-
+    return \"3.5.6\"
 
 def retries(func, retry: int = 3):
     @wraps(func)
diff --git a/pros/conductor/conductor.py b/pros/conductor/conductor.py
index 53129cf..fc61835 100644
--- a/pros/conductor/conductor.py
+++ b/pros/conductor/conductor.py
@@ -129,8 +129,6 @@ class Conductor(Config):
         if 'cortex' not in self.pros_4_default_libraries:
             self.pros_4_default_libraries['cortex'] = []
             needs_saving = True
-        if needs_saving:
-            self.save()
         from pros.common.sentry import add_context
         add_context(self)
 
diff --git a/pros/ga/analytics.py b/pros/ga/analytics.py
index 6f78610..2c993f4 100644
--- a/pros/ga/analytics.py
+++ b/pros/ga/analytics.py
@@ -15,81 +15,16 @@ PROS ANALYTICS CLASS
 
 class Analytics():
     def __init__(self):
-        from pros.config.cli_config import cli_config as get_cli_config
-        self.cli_config = get_cli_config()
-        #If GA hasn't been setup yet (first time install/update)
-        if not self.cli_config.ga:
-            #Default values for GA
-            self.cli_config.ga = {
-                \"enabled\": \"True\",
-                \"ga_id\": \"UA-84548828-8\",
-                \"u_id\": str(uuid.uuid4())
-            }
-        self.cli_config.save()
-        self.sent = False
-        #Variables that the class will use
-        self.gaID = self.cli_config.ga['ga_id']
-        self.useAnalytics = self.cli_config.ga['enabled']
-        self.uID = self.cli_config.ga['u_id']
-        self.pendingRequests = []
+        pass
 
     def send(self,action):
-        if not self.useAnalytics or self.sent:
-            return
-        self.sent=True # Prevent Send from being called multiple times
-        try:
-            #Payload to be sent to GA, idk what some of them are but it works
-            payload = {
-                'v': 1,
-                'tid': self.gaID,
-                'aip': 1,
-                'z': random.random(),
-                'cid': self.uID,
-                't': 'event',
-                'ec': 'action',
-                'ea': action,
-                'el': 'CLI',
-                'ev': '1',
-                'ni': 0
-            }
-
-            session = FuturesSession()          
-
-            #Send payload to GA servers 
-            future = session.post(url=url,
-                             data=payload,
-                             headers={'User-Agent': agent},
-                             timeout=5.0)
-            self.pendingRequests.append(future)
-
-        except Exception as e:
-            from pros.cli.common import logger
-            logger(__name__).warning(\"Unable to send analytics. Do you have a stable internet connection?\", extra={'sentry': False})
+        pass
 
     def set_use(self, value: bool):
-        #Sets if GA is being used or not
-        self.useAnalytics = value
-        self.cli_config.ga['enabled'] = self.useAnalytics
-        self.cli_config.save()
+        pass
     
     def process_requests(self):
-        responses = []
-        for future in as_completed(self.pendingRequests):
-            try:
-                response = future.result()
-                
-                if not response.status_code==200:
-                    print(\"Something went wrong while sending analytics!\")
-                    print(response)
-
-                responses.append(response)
-
-            except Exception:
-                print(\"Something went wrong while sending analytics!\")
-
-
-        self.pendingRequests.clear()
-        return responses
+        pass
 
 
-analytics = Analytics()
\\ No newline at end of file
+analytics = Analytics()
diff --git a/requirements.txt b/requirements.txt
index cdbf7ee..ee50fe4 100644
--- a/requirements.txt
+++ b/requirements.txt
@@ -11,7 +11,6 @@ colorama
 pyzmq
 cobs
 scan-build==2.0.13
-sentry-sdk
 observable
 pypng==0.0.20
 pyinstaller
")))
     (sha256
      (base32
       "1q1qpbgxhpqh6hxqzy6dglzvinlkr0i5lng6liif37719m19gshn"))))
   (build-system pyproject-build-system)
   (native-inputs (list python-setuptools))
   (inputs (list python-click-8.1
                 python-rich-click-1.7
                 python-pyserial
                 python-cachetools
                 python-requests
                 python-requests-futures
                 python-tabulate
                 python-jsonpickle
                 python-semantic-version
                 python-colorama
                 python-pyzmq
                 python-cobs
                 python-observable
                 python-pypng-0.0.20))
   (arguments (list
               #:tests? #f
               #:phases #~(modify-phases %standard-phases
                            (add-after 'unpack 'remove-dependencies
                                       (lambda* (#:key outputs #:allow-other-keys)
                                         (substitute* "requirements.txt"
                                           (("scan-build==2\\.0\\.13")
                                            "")
                                           (("pyinstaller")
                                            "")
                                           (("rich-click==1.7.4")
                                            "rich-click==1.7.*")
                                           (("click==8.1.8")
                                            "click==8.1.*")))))))
   (home-page "https://github.com/purduesigbots/pros-cli")
   (synopsis "Open source development environment for the VEX Platform.")
   (description "Command Line Interface for managing PROS projects. Works with V5 and
the Cortex.")
   (license license:mpl2.0)))

(packages->manifest (list arm-none-eabi-toolchain
                          gnu-make
                          pros-cli
                          pros-2))
