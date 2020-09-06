# Shiny App: East Oakland Facility Inventory

This is the new shiny design made based on the [new wireframe design](https://docs.google.com/presentation/d/1Mvb2ZWz4xAYta-Socco-5_uDWTorkd5bkUg0K2LGmp8/edit?usp=sharing). 

## Frameworks/libraries used 
- `shiny.router`: provides basic routing and url argument parsing functionalities
  - [CRAN documentation](https://cran.r-project.org/web/packages/shiny.router/shiny.router.pdf)
  - [Introduction](https://blog.appsilondatascience.com/shiny-router-a-simple-routing-package-for-shiny/)
  - [URL param parsing tutorial](https://appsilon.com/shiny-router-package/)
- `bootstraplib`: support for bootstrap 4. 
  - [Reference](https://rstudio.github.io/bootstraplib/reference/index.html)
- Bootstrap 4: used for components, styling, and css utilities (e.g. `w-50`)
  - Customization of the components are done with utility classes instead of css as much as possible, for clarity and ease of development
  - [Documentation](https://getbootstrap.com/docs/4.5/getting-started/introduction/)
  - [Cheat sheet](https://hackerthemes.com/bootstrap-cheatsheet/)
- Tachyons: used for extra css utilities
  - [Documentation](https://tachyons.io/docs/)
  - [Cheat sheet](https://roperzh.github.io/tachyons-cheatsheet/)