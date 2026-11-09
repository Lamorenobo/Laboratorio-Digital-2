# 2026-11-08T21:25:59.217346300
import vitis

client = vitis.create_client()
client.set_workspace(path="hami")

platform = client.create_platform_component(name = "HDMI",hw_design = "$COMPONENT_LOCATION/../../Procesador/HDMI.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../HDMI/export/HDMI/HDMI.xpfm",domain = "standalone_ps7_cortexa9_0")

comp = client.get_component(name="app_component")
status = comp.import_files(from_loc="", files=["C:\Users\alina\Downloads\zybo-z7-hdmi-master\zybo-z7-hdmi-master\software"], is_skip_copy_sources = False)

platform = client.get_component(name="HDMI")
status = platform.build()

comp = client.get_component(name="app_component")
comp.build()

domain = platform.add_domain(cpu = "ps7_cortexa9_1",os = "freertos",name = "standalone_ps7_cortexa9_0",display_name = "standalone_ps7_cortexa9_0",support_app = "freertos_hello_world",generate_dtb = False,hw_boot_bin = "")

comp = client.create_app_component(name="hdmi_app",platform = "$COMPONENT_LOCATION/../HDMI/export/HDMI/HDMI.xpfm",domain = "standalone_ps7_cortexa9_0",template = "hello_world")

status = platform.build()

status = platform.build()

comp = client.get_component(name="hdmi_app")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

