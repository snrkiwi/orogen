<% if deployer.browse %>
pkg_check_modules(OrocosOCL REQUIRED orocos-ocl-${OROCOS_TARGET})
include_directories(${OrocosOCL_INCLUDE_DIRS})
link_directories(${OrocosOCL_LIBRARY_DIRS})
<% end %>

<% if deployer.corba_enabled? %>
include_directories(${OrocosCORBA_INCLUDE_DIRS})
link_directories(${OrocosCORBA_LIBRARY_DIRS})
<% end %>

link_directories(${OrocosRTT_LIBRARY_DIRS})

<% deployer.used_toolkits.each do |tk| %>
pkg_check_modules(<%= tk.name %>_TOOLKIT REQUIRED <%= tk.pkg_name %>)
include_directories(${<%= tk.name %>_TOOLKIT_INCLUDE_DIRS})
link_directories(${<%= tk.name %>_TOOLKIT_LIBRARY_DIRS})
<% if deployer.corba_enabled? %>
pkg_check_modules(<%= tk.name %>_TRANSPORT_CORBA REQUIRED <%= tk.pkg_corba_name %>)
include_directories(${<%= tk.name %>_TOOLKIT_INCLUDE_DIRS})
link_directories(${<%= tk.name %>_TOOLKIT_LIBRARY_DIRS})
<% end %>
<% end %>
<% component.used_task_libraries.each do |pkg| %>
pkg_check_modules(<%= pkg.name %>_TASKLIB REQUIRED <%= pkg.name %>-tasks-${OROCOS_TARGET})
include_directories(${<%= pkg.name %>_TASKLIB_INCLUDE_DIRS})
link_directories(${<%= pkg.name %>_TASKLIB_LIBRARY_DIRS})
<% end %>

include_directories(${OrocosRTT_INCLUDE_DIRS})
add_definitions(${OrocosRTT_CFLAGS_OTHER})
add_executable(<%= deployer.name %> ${CMAKE_SOURCE_DIR}/<%= Generation::AUTOMATIC_AREA_NAME %>/main-<%= deployer.name %>.cpp)
<% if component.toolkit %>
target_link_libraries(<%= deployer.name %> <%= component.name %>-toolkit-${OROCOS_TARGET})
<% if deployer.corba_enabled? %>
target_link_libraries(<%= deployer.name %> <%= component.name %>-transport-corba-${OROCOS_TARGET})
<% end %>
<% end %>
<% deployer.used_toolkits.each do |tk| %>
target_link_libraries(<%= deployer.name %> ${<%= tk.name %>_TOOLKIT_LIBRARIES})
<% if deployer.corba_enabled? %>
target_link_libraries(<%= deployer.name %> ${<%= tk.name %>_TRANSPORT_CORBA_LIBRARIES})
<% end %>
<% end %>
<% component.used_task_libraries.each do |pkg|
    name = pkg.name%>
target_link_libraries(<%= deployer.name %> ${<%= name %>_TASKLIB_LIBRARIES})
<% end %>


<% if !component.self_tasks.empty? %>
target_link_libraries(<%= deployer.name %> <%= component.name %>-tasks-${OROCOS_TARGET})
<% end %>
<% if deployer.install? %>
install(TARGETS <%= deployer.name %>
    RUNTIME DESTINATION bin)
<% end %>

configure_file(<%= Generation::AUTOMATIC_AREA_NAME %>/<%= deployer.name %>.pc.in
    orogen-<%= deployer.name %>.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/orogen-<%= deployer.name %>.pc
    DESTINATION lib/pkgconfig)

<% if deployer.corba_enabled? %>
target_link_libraries(<%= deployer.name %> ${OrocosCORBA_LIBRARIES})
<% elsif deployer.browse %>
target_link_libraries(<%= deployer.name %> ${OrocosOCL_LIBRARIES})
<% end %>

